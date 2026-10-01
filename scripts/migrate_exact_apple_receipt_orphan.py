#!/usr/bin/env python3

import argparse
import hashlib
import json
import subprocess
import sys
import urllib.error
import urllib.parse
import urllib.request
from datetime import datetime, timezone


PROJECT = "flowai-demo-project"

PLATFORM = "ios"

ORIGINAL_TRANSACTION_ID = (
    "2000001238003319"
)

OWNER_UID = (
    "dsUBCusojhMsvUTT0bMIbCIBvNE2"
)

OWNERSHIP_SOURCE = (
    "legacy_conflict_adjudicated"
)

ADJUDICATION_EVIDENCE = (
    "current_verified_restore_plus_"
    "earliest_historical_owner"
)

EXPECTED_SCHEMA_VERSION = "1"

EXPECTED_UPDATE_TIME = (
    "2026-09-19T21:46:53.927024Z"
)

OWNER_KEY = hashlib.sha256(
    (
        f"{PLATFORM}:"
        f"{ORIGINAL_TRANSACTION_ID}"
    ).encode()
).hexdigest()

EXPECTED_OWNER_KEY = (
    "00000000000000000000000000000000"
    "00000000000000000000000000000000"
)

if OWNER_KEY != EXPECTED_OWNER_KEY:
    raise SystemExit(
        "OWNER_KEY_CONSTANT_MISMATCH"
    )


def access_token():
    result = subprocess.run(
        [
            "gcloud",
            "auth",
            "print-access-token",
        ],
        check=True,
        capture_output=True,
        text=True,
    )

    token = result.stdout.strip()

    if not token:
        raise RuntimeError(
            "EMPTY_GCLOUD_ACCESS_TOKEN"
        )

    return token


def request_json(
    method,
    url,
    token,
    body=None,
):
    data = None

    headers = {
        "Authorization":
            f"Bearer {token}",
        "x-goog-user-project":
            PROJECT,
    }

    if body is not None:
        data = json.dumps(
            body
        ).encode()

        headers[
            "Content-Type"
        ] = "application/json"

    request = urllib.request.Request(
        url,
        data=data,
        headers=headers,
        method=method,
    )

    try:
        with urllib.request.urlopen(
            request
        ) as response:
            raw = response.read()

            if not raw:
                return {}

            return json.loads(
                raw.decode()
            )
    except urllib.error.HTTPError as exc:
        raw = exc.read().decode(
            errors="replace"
        )

        raise RuntimeError(
            "HTTP_ERROR "
            f"{exc.code}: {raw}"
        ) from exc


def string_field(
    fields,
    name,
):
    value = fields.get(
        name,
        {},
    )

    result = value.get(
        "stringValue"
    )

    return (
        result
        if isinstance(result, str)
        else None
    )


def integer_field(
    fields,
    name,
):
    value = fields.get(
        name,
        {},
    )

    result = value.get(
        "integerValue"
    )

    return (
        str(result)
        if result is not None
        else None
    )


def verify_owner(
    document,
):
    fields = document.get(
        "fields",
        {},
    )

    actual = {
        "ownerUid":
            string_field(
                fields,
                "ownerUid",
            ),
        "platform":
            string_field(
                fields,
                "platform",
            ),
        "originalTransactionId":
            string_field(
                fields,
                "originalTransactionId",
            ),
        "ownershipSource":
            string_field(
                fields,
                "ownershipSource",
            ),
        "adjudicationEvidence":
            string_field(
                fields,
                "adjudicationEvidence",
            ),
        "schemaVersion":
            integer_field(
                fields,
                "schemaVersion",
            ),
        "ownerStatus":
            string_field(
                fields,
                "ownerStatus",
            ),
        "deletedOwnerUid":
            string_field(
                fields,
                "deletedOwnerUid",
            ),
        "updateTime":
            document.get(
                "updateTime"
            ),
    }

    expected = {
        "ownerUid":
            OWNER_UID,
        "platform":
            PLATFORM,
        "originalTransactionId":
            ORIGINAL_TRANSACTION_ID,
        "ownershipSource":
            OWNERSHIP_SOURCE,
        "adjudicationEvidence":
            ADJUDICATION_EVIDENCE,
        "schemaVersion":
            EXPECTED_SCHEMA_VERSION,
        "ownerStatus":
            None,
        "deletedOwnerUid":
            None,
        "updateTime":
            EXPECTED_UPDATE_TIME,
    }

    print(
        "OWNER_DOCUMENT_FACTS="
    )

    for key in expected:
        print(
            f"  {key}="
            f"{actual[key]}"
        )

    if actual != expected:
        raise RuntimeError(
            "OWNER_DOCUMENT_FACT_MISMATCH"
        )

    print(
        "OWNER_DOCUMENT_EXACT_MATCH=PASS"
    )


def verify_old_uid_absent(
    token,
):
    url = (
        "https://identitytoolkit."
        "googleapis.com/v1/projects/"
        f"{PROJECT}/accounts:lookup"
    )

    response = request_json(
        "POST",
        url,
        token,
        {
            "localId": [
                OWNER_UID
            ]
        },
    )

    users = response.get(
        "users",
        [],
    )

    print(
        "OLD_UID_AUTH_MATCH_COUNT="
        f"{len(users)}"
    )

    if users:
        raise RuntimeError(
            "OLD_UID_STILL_PRESENT"
        )

    print(
        "OLD_UID_AUTH_STATE=ABSENT"
    )


def build_commit_body():
    document_name = (
        "projects/"
        f"{PROJECT}/"
        "databases/(default)/documents/"
        "premiumReceiptOwners/"
        f"{OWNER_KEY}"
    )

    return {
        "writes": [
            {
                "update": {
                    "name":
                        document_name,
                    "fields": {
                        "ownerStatus": {
                            "stringValue":
                                "auth_deleted"
                        },
                        "deletedOwnerUid": {
                            "stringValue":
                                OWNER_UID
                        },
                        "schemaVersion": {
                            "integerValue":
                                "2"
                        },
                    },
                },
                "updateMask": {
                    "fieldPaths": [
                        "ownerStatus",
                        "deletedOwnerUid",
                        "schemaVersion",
                    ]
                },
                "updateTransforms": [
                    {
                        "fieldPath":
                            "deletedAt",
                        "setToServerValue":
                            "REQUEST_TIME",
                    }
                ],
                "currentDocument": {
                    "updateTime":
                        EXPECTED_UPDATE_TIME
                },
            }
        ]
    }


def main():
    parser = argparse.ArgumentParser()

    parser.add_argument(
        "--execute",
        action="store_true",
    )

    parser.add_argument(
        "--confirm-owner-key",
        default="",
    )

    args = parser.parse_args()

    active_project = subprocess.run(
        [
            "gcloud",
            "config",
            "get-value",
            "project",
        ],
        check=True,
        capture_output=True,
        text=True,
    ).stdout.strip()

    print(
        "ACTIVE_GCLOUD_PROJECT="
        f"{active_project}"
    )

    if active_project != PROJECT:
        raise RuntimeError(
            "GCLOUD_PROJECT_MISMATCH"
        )

    token = access_token()

    owner_url = (
        "https://firestore.googleapis.com/"
        "v1/projects/"
        f"{PROJECT}/"
        "databases/(default)/documents/"
        "premiumReceiptOwners/"
        f"{OWNER_KEY}"
    )

    owner_document = request_json(
        "GET",
        owner_url,
        token,
    )

    verify_owner(
        owner_document
    )

    verify_old_uid_absent(
        token
    )

    commit_body = (
        build_commit_body()
    )

    print(
        "OWNER_KEY="
        f"{OWNER_KEY}"
    )

    print(
        "MIGRATION_EFFECT="
        "active_schema1 -> "
        "auth_deleted_schema2"
    )

    print(
        "NEW_OWNER_UID_WRITTEN=NO"
    )

    print(
        "OWNERSHIP_TRANSFER=NO"
    )

    print(
        "UPDATE_PRECONDITION="
        f"{EXPECTED_UPDATE_TIME}"
    )

    if not args.execute:
        print(
            "MODE=DRY_RUN"
        )

        print(
            "DRY_RUN_EXACT_OWNER_MIGRATION="
            "PASS_NO_WRITE"
        )

        return

    if (
        args.confirm_owner_key
        != OWNER_KEY
    ):
        raise RuntimeError(
            "EXECUTION_CONFIRMATION_MISMATCH"
        )

    commit_url = (
        "https://firestore.googleapis.com/"
        "v1/projects/"
        f"{PROJECT}/"
        "databases/(default)/documents:commit"
    )

    result = request_json(
        "POST",
        commit_url,
        token,
        commit_body,
    )

    if not result.get(
        "writeResults"
    ):
        raise RuntimeError(
            "FIRESTORE_COMMIT_NO_WRITE_RESULT"
        )

    print(
        "MODE=EXECUTE"
    )

    print(
        "EXACT_OWNER_MIGRATION_WRITE=PASS"
    )


if __name__ == "__main__":
    main()
