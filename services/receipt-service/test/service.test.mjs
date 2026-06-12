import assert from "node:assert/strict";
import {
  once,
} from "node:events";
import {
  readFile,
} from "node:fs/promises";
import test from "node:test";
import {
  createReceiptServer,
  extractBearerToken,
  runtimeArchitecture,
} from "../lib/index.js";

test("declares the isolated runtime architecture", () => {
  assert.equal(runtimeArchitecture, "minimal-cloud-run");
});

test("extracts only a valid Bearer token", () => {
  assert.equal(extractBearerToken(undefined), null);
  assert.equal(extractBearerToken("Basic abc"), null);
  assert.equal(extractBearerToken("Bearer "), null);
  assert.equal(extractBearerToken("Bearer token-value"), "token-value");
});

test("health endpoint works without credentials", async () => {
  const server = createReceiptServer();

  try {
    server.listen(0, "127.0.0.1");
    await once(server, "listening");

    const address = server.address();

    assert.notEqual(address, null);
    assert.notEqual(typeof address, "string");

    if (
      address === null ||
      typeof address === "string"
    ) {
      throw new Error("server_address_unavailable");
    }

    const response = await fetch(
      `http://127.0.0.1:${address.port}/healthz`,
    );

    assert.equal(response.status, 200);
    assert.equal(
      response.headers.get("cache-control"),
      "no-store",
    );

    const body = await response.json();

    assert.equal(body.status, "ok");
    assert.equal(
      body.architecture,
      "minimal-cloud-run",
    );
  } finally {
    server.close();
    await once(server, "close");
  }
});

test("protected receipt routes reject missing authentication", async () => {
  const server = createReceiptServer();

  try {
    server.listen(0, "127.0.0.1");
    await once(server, "listening");

    const address = server.address();

    assert.notEqual(address, null);
    assert.notEqual(typeof address, "string");

    if (
      address === null ||
      typeof address === "string"
    ) {
      throw new Error("server_address_unavailable");
    }

    const response = await fetch(
      `http://127.0.0.1:${address.port}/v1/receipts/google`,
      {
        method: "POST",
        headers: {
          "Content-Type": "application/json",
        },
        body: JSON.stringify({
          packageName: "com.flowai.app",
          platform: "android",
          productId: "flow_ai_premium_monthly",
          receipt: "test-token",
        }),
      },
    );

    assert.equal(response.status, 401);

    const body = await response.json();

    assert.equal(
      body.error,
      "authentication_required",
    );
  } finally {
    server.close();
    await once(server, "close");
  }
});

test("source enforces the keyless authenticated contract", async () => {
  const source = await readFile(
    new URL("../src/index.ts", import.meta.url),
    "utf8",
  );

  for (const requiredToken of [
    "jwtVerify",
    "createRemoteJWKSet",
    "securetoken.google.com",
    "generateAccessToken",
    "androidpublisher",
    "premiumEntitlements",
    "FLOW_AI_APPLE_ISSUER_ID_NEXT",
    "FLOW_AI_APPLE_KEY_ID_NEXT",
    "FLOW_AI_APPLE_PRIVATE_KEY_P8_NEXT",
    "FLOW_AI_GOOGLE_PLAY_SERVICE_ACCOUNT",
  ]) {
    assert.match(source, new RegExp(requiredToken.replace("/", "\\/")));
  }

  for (const forbiddenToken of [
    "body.userId",
    "GOOGLE_SERVICE_ACCOUNT_JSON",
    "private_key",
    "client_email",
    "firebase-admin",
    "firebase-functions",
  ]) {
    assert.doesNotMatch(
      source,
      new RegExp(forbiddenToken.replace("-", "\\-")),
    );
  }
});
