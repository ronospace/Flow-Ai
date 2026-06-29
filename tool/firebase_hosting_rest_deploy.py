#!/usr/bin/env python3
from __future__ import annotations

import argparse
import gzip
import hashlib
import json
import os
import sys
import tempfile
import time
import urllib.error
import urllib.parse
import urllib.request
from pathlib import Path
from typing import Any

API = "https://firebasehosting.googleapis.com/v1beta1"
RETRYABLE = {408, 429, 500, 502, 503, 504}


class DeployError(RuntimeError):
    pass


def call(
    method: str,
    url: str,
    token: str,
    *,
    body: Any | None = None,
    binary: bytes | None = None,
    expected: tuple[int, ...] = (200,),
    allow: tuple[int, ...] = (),
) -> tuple[int, Any]:
    headers = {
        "Authorization": f"Bearer {token}",
        "Accept": "application/json",
        "User-Agent": "flow-ai-hosting-rest/1",
    }
    data = None

    if body is not None:
        data = json.dumps(
            body,
            separators=(",", ":"),
        ).encode("utf-8")
        headers["Content-Type"] = "application/json"
    elif binary is not None:
        data = binary
        headers["Content-Type"] = "application/octet-stream"

    for attempt in range(5):
        request = urllib.request.Request(
            url,
            data=data,
            headers=headers,
            method=method,
        )

        try:
            with urllib.request.urlopen(
                request,
                timeout=180,
            ) as response:
                status = response.status
                payload = response.read()
        except urllib.error.HTTPError as exc:
            status = exc.code
            payload = exc.read()
        except urllib.error.URLError as exc:
            if attempt == 4:
                raise DeployError(
                    f"Network request failed: {exc}"
                ) from exc

            time.sleep(2 ** attempt)
            continue

        if status in expected or status in allow:
            if not payload:
                return status, None

            try:
                return status, json.loads(payload)
            except json.JSONDecodeError:
                return (
                    status,
                    payload.decode(
                        "utf-8",
                        errors="replace",
                    ),
                )

        if status in RETRYABLE and attempt < 4:
            time.sleep(2 ** attempt)
            continue

        text = payload.decode(
            "utf-8",
            errors="replace",
        )

        try:
            parsed = json.loads(text)
            detail = parsed.get("error", parsed)

            if isinstance(detail, dict):
                message = (
                    detail.get("message")
                    or detail.get("status")
                    or text
                )
            else:
                message = text
        except json.JSONDecodeError:
            message = text[:1000]

        raise DeployError(
            f"HTTP {status}: {message}"
        )

    raise DeployError(
        "Request retry loop exhausted"
    )


def serving_config(
    firebase_json: Path,
) -> dict[str, Any]:
    raw = json.loads(
        firebase_json.read_text()
    )
    hosting = raw["hosting"]

    if not isinstance(hosting, dict):
        raise DeployError(
            "Exactly one Hosting configuration is required"
        )

    config: dict[str, Any] = {}
    rewrites = []

    for rule in hosting.get("rewrites", []):
        if "destination" not in rule:
            raise DeployError(
                "Only static-path rewrites are supported"
            )

        rewrites.append(
            {
                (
                    "regex"
                    if "regex" in rule
                    else "glob"
                ): rule.get(
                    "regex",
                    rule.get("source"),
                ),
                "path": rule["destination"],
            }
        )

    if rewrites:
        config["rewrites"] = rewrites

    if "cleanUrls" in hosting:
        config["cleanUrls"] = bool(
            hosting["cleanUrls"]
        )

    if "trailingSlash" in hosting:
        config["trailingSlashBehavior"] = (
            "ADD"
            if hosting["trailingSlash"]
            else "REMOVE"
        )

    return config


def prepare_assets(
    public: Path,
    work: Path,
) -> tuple[
    dict[str, str],
    dict[str, Path],
    int,
]:
    manifest: dict[str, str] = {}
    archives: dict[str, Path] = {}
    total = 0

    for source in sorted(
        public.rglob("*")
    ):
        if not source.is_file():
            continue

        relative = source.relative_to(
            public
        )

        if (
            any(
                part.startswith(".")
                for part in relative.parts
            )
            or "node_modules"
            in relative.parts
        ):
            continue

        data = source.read_bytes()
        total += len(data)

        archive = (
            work
            / f"{len(manifest):08d}.gz"
        )

        with archive.open("wb") as output:
            with gzip.GzipFile(
                filename="",
                mode="wb",
                fileobj=output,
                compresslevel=9,
                mtime=0,
            ) as compressed:
                compressed.write(data)

        digest = hashlib.sha256(
            archive.read_bytes()
        ).hexdigest()

        manifest[
            f"/{relative.as_posix()}"
        ] = digest

        archives.setdefault(
            digest,
            archive,
        )

    if not manifest:
        raise DeployError(
            "No deployable files found"
        )

    return manifest, archives, total


def ensure_channel(
    site: str,
    channel_id: str,
    ttl: str | None,
    token: str,
) -> dict[str, Any]:
    name = (
        f"sites/{site}/channels/"
        f"{channel_id}"
    )
    url = f"{API}/{name}"

    status, current = call(
        "GET",
        url,
        token,
        allow=(404,),
    )

    if status == 404:
        channel_body: dict[str, Any] = {
            "retainedReleaseCount": 3,
            "labels": {
                "managed-by":
                    "github-actions",
                "application":
                    "flow-ai",
            },
        }

        if ttl:
            channel_body["ttl"] = ttl

        query = urllib.parse.urlencode(
            {"channelId": channel_id}
        )

        return call(
            "POST",
            (
                f"{API}/sites/{site}"
                f"/channels?{query}"
            ),
            token,
            body=channel_body,
        )[1]

    if (
        channel_id == "live"
        or not ttl
    ):
        return current

    query = urllib.parse.urlencode(
        {
            "updateMask":
                "ttl,"
                "retainedReleaseCount,"
                "labels"
        }
    )

    return call(
        "PATCH",
        f"{url}?{query}",
        token,
        body={
            "name": name,
            "ttl": ttl,
            "retainedReleaseCount": 3,
            "labels": {
                "managed-by":
                    "github-actions",
                "application":
                    "flow-ai",
            },
        },
    )[1]


def deploy(
    args: argparse.Namespace,
) -> dict[str, Any]:
    token = os.environ.get(
        "FIREBASE_ACCESS_TOKEN",
        "",
    ).strip()

    if not token:
        raise DeployError(
            "FIREBASE_ACCESS_TOKEN is missing"
        )

    public = Path(
        args.public
    ).resolve()

    firebase_json = Path(
        args.firebase_json
    ).resolve()

    if (
        not public.is_dir()
        or not firebase_json.is_file()
    ):
        raise DeployError(
            "Public directory or firebase.json is missing"
        )

    version_name = None
    released = False

    try:
        with tempfile.TemporaryDirectory(
            prefix="flow-ai-hosting-"
        ) as temp:
            manifest, archives, total = (
                prepare_assets(
                    public,
                    Path(temp),
                )
            )

            version = call(
                "POST",
                (
                    f"{API}/sites/"
                    f"{args.site}/versions"
                ),
                token,
                body={
                    "config":
                        serving_config(
                            firebase_json
                        )
                },
            )[1]

            version_name = version["name"]

            required: set[str] = set()
            upload_url = ""
            entries = sorted(
                manifest.items()
            )

            for offset in range(
                0,
                len(entries),
                1000,
            ):
                populated = call(
                    "POST",
                    (
                        f"{API}/"
                        f"{version_name}"
                        ":populateFiles"
                    ),
                    token,
                    body={
                        "files": dict(
                            entries[
                                offset:
                                offset + 1000
                            ]
                        )
                    },
                )[1]

                required.update(
                    populated.get(
                        "uploadRequiredHashes",
                        [],
                    )
                )

                upload_url = (
                    populated.get(
                        "uploadUrl",
                        upload_url,
                    )
                )

            if (
                required
                and not upload_url
            ):
                raise DeployError(
                    "Hosting returned no upload URL"
                )

            for digest in sorted(
                required
            ):
                archive = archives.get(
                    digest
                )

                if archive is None:
                    raise DeployError(
                        "Hosting requested an "
                        f"unknown hash: {digest}"
                    )

                call(
                    "POST",
                    (
                        f"{upload_url}/"
                        f"{digest}"
                    ),
                    token,
                    binary=(
                        archive.read_bytes()
                    ),
                )

            query = (
                urllib.parse.urlencode(
                    {"updateMask": "status"}
                )
            )

            finalized = call(
                "PATCH",
                (
                    f"{API}/"
                    f"{version_name}"
                    f"?{query}"
                ),
                token,
                body={
                    "status": "FINALIZED"
                },
            )[1]

            if (
                finalized.get("status")
                != "FINALIZED"
            ):
                raise DeployError(
                    "Version did not finalize"
                )

            ensure_channel(
                args.site,
                args.channel,
                (
                    args.ttl
                    if args.channel
                    != "live"
                    else None
                ),
                token,
            )

            parent = (
                f"sites/{args.site}"
                if args.channel == "live"
                else (
                    f"sites/{args.site}"
                    f"/channels/"
                    f"{args.channel}"
                )
            )

            query = (
                urllib.parse.urlencode(
                    {
                        "versionName":
                            version_name
                    }
                )
            )

            release = call(
                "POST",
                (
                    f"{API}/{parent}"
                    f"/releases?{query}"
                ),
                token,
                body={
                    "message":
                        args.message
                },
            )[1]

            released = True

            state = call(
                "GET",
                (
                    f"{API}/sites/"
                    f"{args.site}"
                    f"/channels/"
                    f"{args.channel}"
                ),
                token,
            )[1]

            active_version = (
                state
                .get("release", {})
                .get("version", {})
                .get("name")
            )

            if (
                active_version
                != version_name
            ):
                raise DeployError(
                    "Channel verification failed"
                )

            return {
                "status": "success",
                "site": args.site,
                "channel": args.channel,
                "channelUrl":
                    state.get("url"),
                "version":
                    version_name,
                "release":
                    release.get("name"),
                "releaseTime":
                    release.get(
                        "releaseTime"
                    ),
                "fileCount":
                    len(manifest),
                "uploadedHashCount":
                    len(required),
                "uncompressedBytes":
                    total,
            }

    except Exception:
        if (
            version_name
            and not released
        ):
            try:
                call(
                    "DELETE",
                    (
                        f"{API}/"
                        f"{version_name}"
                    ),
                    token,
                    expected=(200, 204),
                )

                print(
                    "abandoned_version_"
                    f"deleted={version_name}",
                    file=sys.stderr,
                )
            except Exception as cleanup:
                print(
                    "abandoned_version_"
                    "cleanup_failed="
                    f"{cleanup}",
                    file=sys.stderr,
                )

        raise


def self_test() -> None:
    with tempfile.TemporaryDirectory() as temp:
        root = Path(temp)

        config = root / "firebase.json"
        config.write_text(
            json.dumps(
                {
                    "hosting": {
                        "rewrites": [
                            {
                                "source": "**",
                                "destination":
                                    "/index.html",
                            }
                        ]
                    }
                }
            )
        )

        assert serving_config(
            config
        ) == {
            "rewrites": [
                {
                    "glob": "**",
                    "path":
                        "/index.html",
                }
            ]
        }

        public = root / "public"
        public.mkdir()

        (
            public / "index.html"
        ).write_text("Flow AI")

        (
            public / ".hidden"
        ).write_text("skip")

        work = root / "work"
        work.mkdir()

        manifest, archives, total = (
            prepare_assets(
                public,
                work,
            )
        )

        assert list(manifest) == [
            "/index.html"
        ]
        assert len(archives) == 1
        assert total == 7

    print("self_test=passed")


def main() -> int:
    parser = argparse.ArgumentParser()

    parser.add_argument("--site")
    parser.add_argument("--public")
    parser.add_argument("--channel")
    parser.add_argument("--ttl")
    parser.add_argument(
        "--message",
        default="",
    )
    parser.add_argument(
        "--firebase-json",
        default="firebase.json",
    )
    parser.add_argument("--output")
    parser.add_argument(
        "--self-test",
        action="store_true",
    )

    args = parser.parse_args()

    if args.self_test:
        self_test()
        return 0

    for field in (
        "site",
        "public",
        "channel",
        "output",
    ):
        if not getattr(args, field):
            parser.error(
                f"--{field} is required"
            )

    if (
        args.channel != "live"
        and not args.ttl
    ):
        parser.error(
            "--ttl is required for "
            "preview channels"
        )

    try:
        result = deploy(args)

        output = Path(args.output)
        output.parent.mkdir(
            parents=True,
            exist_ok=True,
        )

        output.write_text(
            json.dumps(
                result,
                indent=2,
                sort_keys=True,
            )
            + "\n"
        )

        print(
            "firebase_hosting_rest_"
            "deploy=success"
        )
        print(
            f"channel="
            f"{result['channel']}"
        )
        print(
            "channel_url="
            + str(
                result.get("channelUrl")
                or "unavailable"
            )
        )
        print(
            f"version="
            f"{result['version']}"
        )
        print(
            f"file_count="
            f"{result['fileCount']}"
        )

        return 0

    except Exception as exc:
        print(
            "firebase_hosting_rest_"
            f"deploy=failed: {exc}",
            file=sys.stderr,
        )
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
