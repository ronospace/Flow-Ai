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
  assert.equal(extractBearerToken("Bearer REDACTED_VALUE"), "REDACTED_VALUE");
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
      `http://127.0.0.1:${address.port}/health`,
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
          productId: "flow_ai_premium_monthly",
          purchaseToken: "REDACTED_VALUE",
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
    "FLOW_AI_APPLE_ISSUER_ID",
    "FLOW_AI_APPLE_KEY_ID",
    "FLOW_AI_APPLE_PRIVATE_KEY_P8",
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

test("source matches the published mobile payload contract", async () => {
  const source = await readFile(
    new URL("../src/index.ts", import.meta.url),
    "utf8",
  );

  for (const requiredPattern of [
    /const purchaseToken = requiredString\(\s*body,\s*"purchaseToken",/,
    /const transactionId = requiredString\(\s*body,\s*"transactionId",/,
    /const environment = requiredString\(\s*body,\s*"environment",/,
    /const uid = await requireFirebaseUid\(request\);/,
    /verifyGoogleSubscription\(\s*purchaseToken,/,
    /persistAfterReceiptOwnership\([\s\S]*uid,[\s\S]*result,[\s\S]*assertReceiptOwnership,[\s\S]*persistValidatedEntitlement,[\s\S]*\);/,
  ]) {
    assert.match(source, requiredPattern);
  }

  for (const forbiddenPattern of [
    /const receipt = requiredString\(/,
    /const requestPlatform = requiredString\(/,
    /verifyGoogleSubscription\(\s*receipt,/,
    /body\.userId/,
  ]) {
    assert.doesNotMatch(source, forbiddenPattern);
  }
});


test("source enforces Apple subscription lifecycle semantics", async () => {
  const source = await readFile(
    new URL("../src/index.ts", import.meta.url),
    "utf8",
  );

  for (const pattern of [
    /getAllSubscriptionStatuses\(/,
    /Status\.REVOKED/,
    /Status\.EXPIRED/,
    /Status\.BILLING_RETRY/,
    /Status\.BILLING_GRACE_PERIOD/,
    /verifyAndDecodeRenewalInfo\(/,
    /gracePeriodExpiresDate/,
  ]) {
    assert.match(source, pattern);
  }
});


test("source enforces Google subscription lifecycle semantics", async () => {
  const source = await readFile(
    new URL("../src/index.ts", import.meta.url),
    "utf8",
  );

  for (const pattern of [
    /SUBSCRIPTION_STATE_ACTIVE/,
    /SUBSCRIPTION_STATE_IN_GRACE_PERIOD/,
    /SUBSCRIPTION_STATE_CANCELED/,
    /paid_through_cancellation/,
    /expiryMillis <= Date\.now\(\)/,
  ]) {
    assert.match(source, pattern);
  }

  assert.doesNotMatch(
    source,
    /activeGoogleSubscriptionStates/,
  );
});


test("validated receipts expose and persist lifecycle status", async () => {
  const source = await readFile(
    new URL("../src/index.ts", import.meta.url),
    "utf8",
  );

  assert.match(
    source,
    /lifecycleStatus: result\.lifecycleStatus/,
  );

  assert.match(
    source,
    /stringValue: result\.lifecycleStatus/,
  );
});


test("receipt ownership gate is deterministic, atomic, and fail-closed", async () => {
  const source = await readFile(
    new URL("../src/index.ts", import.meta.url),
    "utf8",
  );

  for (const pattern of [
    /createHash\("sha256"\)/,
    /premiumReceiptOwners/,
    /first_verified_claim/,
    /legacy_single_owner/,
    /deleted_owner_transfer/,
    /auth_deleted/,
    /currentDocument\.updateTime/,
    /queryLegacyReceiptOwners/,
    /createReceiptOwnerAtomically/,
    /transferDeletedReceiptOwnerAtomically/,
    /response\.status === 409/,
    /receipt_owner_conflict/,
    /persistAfterReceiptOwnership\([\s\S]*uid,[\s\S]*result,[\s\S]*assertReceiptOwnership,[\s\S]*persistValidatedEntitlement,[\s\S]*\);/,
  ]) {
    assert.match(source, pattern);
  }

  assert.doesNotMatch(
    source,
    /persistAfterReceiptOwnership\([\s\S]*persistValidatedEntitlement,[\s\S]*assertReceiptOwnership/,
  );
});

test("C7 ownership behavior matrix", async () => {
  const mod = await import("../lib/index.js");
  const {
    assertReceiptOwnershipWithDependencies,
    persistAfterReceiptOwnership,
  } = mod;

  const result = {
    platform: "apple",
    originalTransactionId: "orig-123",
    transactionId: "tx-123",
    productId: "premium.monthly",
    expirationDate: new Date("2030-01-01T00:00:00Z"),
    lifecycleStatus: "active",
  };

  const makeDeps = ({
    existingOwner = null,
    legacy = { kind: "none" },
    createResult = "created",
    racedOwner = null,
    transferResult = "transferred",
  } = {}) => {
    const calls = [];

    return {
      calls,
      deps: {
        runtimeAccessToken: async () => "token",
        readReceiptOwner: async () => {
          calls.push("read");

          if (
            calls.filter(
              (x) => x === "read",
            ).length > 1
          ) {
            return racedOwner;
          }

          return existingOwner;
        },
        queryLegacyReceiptOwners: async () => {
          calls.push("legacy");
          return legacy;
        },
        createReceiptOwnerAtomically: async (
          token,
          key,
          ownerUid,
          receipt,
          source,
        ) => {
          calls.push([
            "create",
            ownerUid,
            source,
          ]);

          return createResult;
        },
        transferDeletedReceiptOwnerAtomically:
          async (
            token,
            key,
            priorOwner,
            newOwnerUid,
          ) => {
            calls.push([
              "transfer",
              priorOwner.ownerUid,
              newOwnerUid,
            ]);

            return transferResult;
          },
      },
    };
  };

  // 1. first claim
  {
    const { deps, calls } = makeDeps();
    await assertReceiptOwnershipWithDependencies(
      "uid-A",
      result,
      deps,
    );
    assert.deepEqual(
      calls.find((x) => Array.isArray(x)),
      ["create", "uid-A", "first_verified_claim"],
    );
  }

  // 2. same owner idempotence
  {
    const { deps, calls } = makeDeps({
      existingOwner: {
        kind: "active",
        ownerUid: "uid-A",
        updateTime: "t-active-a",
      },
    });
    await assertReceiptOwnershipWithDependencies(
      "uid-A",
      result,
      deps,
    );
    assert.equal(
      calls.some((x) => Array.isArray(x)),
      false,
    );
  }

  // 3. different owner -> 409
  {
    const { deps } = makeDeps({
      existingOwner: {
        kind: "active",
        ownerUid: "uid-B",
        updateTime: "t-active-b",
      },
    });
    await assert.rejects(
      () =>
        assertReceiptOwnershipWithDependencies(
          "uid-A",
          result,
          deps,
        ),
      (error) =>
        error?.statusCode === 409 ||
        error?.status === 409,
    );
  }

  // 3A. authoritative deleted owner transfers to verified new UID
  {
    const { deps, calls } = makeDeps({
      existingOwner: {
        kind: "auth_deleted",
        ownerUid: "uid-OLD",
        deletedOwnerUid: "uid-OLD",
        updateTime: "t-deleted",
      },
    });

    await assertReceiptOwnershipWithDependencies(
      "uid-NEW",
      result,
      deps,
    );

    assert.deepEqual(
      calls.find(
        (value) =>
          Array.isArray(value) &&
          value[0] === "transfer",
      ),
      [
        "transfer",
        "uid-OLD",
        "uid-NEW",
      ],
    );
  }

  // 3B. deleted identity cannot reclaim its released chain
  {
    const { deps } = makeDeps({
      existingOwner: {
        kind: "auth_deleted",
        ownerUid: "uid-A",
        deletedOwnerUid: "uid-A",
        updateTime: "t-deleted",
      },
    });

    await assert.rejects(
      () =>
        assertReceiptOwnershipWithDependencies(
          "uid-A",
          result,
          deps,
        ),
      /deleted identity cannot reclaim itself/,
    );
  }

  // 3C. transfer CAS race fails closed if another UID wins
  {
    const { deps } = makeDeps({
      existingOwner: {
        kind: "auth_deleted",
        ownerUid: "uid-OLD",
        deletedOwnerUid: "uid-OLD",
        updateTime: "t-deleted",
      },
      transferResult: "precondition_failed",
      racedOwner: {
        kind: "active",
        ownerUid: "uid-WINNER",
        updateTime: "t-winner",
      },
    });

    await assert.rejects(
      () =>
        assertReceiptOwnershipWithDependencies(
          "uid-LOSER",
          result,
          deps,
        ),
      (error) =>
        error?.statusCode === 409 ||
        error?.status === 409,
    );
  }

  // 3D. transfer CAS race is idempotent if this UID already won
  {
    const { deps } = makeDeps({
      existingOwner: {
        kind: "auth_deleted",
        ownerUid: "uid-OLD",
        deletedOwnerUid: "uid-OLD",
        updateTime: "t-deleted",
      },
      transferResult: "precondition_failed",
      racedOwner: {
        kind: "active",
        ownerUid: "uid-NEW",
        updateTime: "t-new",
      },
    });

    await assertReceiptOwnershipWithDependencies(
      "uid-NEW",
      result,
      deps,
    );
  }

  // 4. no entitlement write after ownership rejection
  {
    let persisted = false;

    await assert.rejects(
      () =>
        persistAfterReceiptOwnership(
          "uid-A",
          result,
          async () => {
            const error = new Error(
              "receipt_owner_conflict",
            );
            error.statusCode = 409;
            throw error;
          },
          async () => {
            persisted = true;
          },
        ),
    );

    assert.equal(persisted, false);
  }

  // 5. legacy same-owner migration
  {
    const { deps, calls } = makeDeps({
      legacy: {
        kind: "single",
        uid: "uid-A",
      },
    });

    await assertReceiptOwnershipWithDependencies(
      "uid-A",
      result,
      deps,
    );

    assert.deepEqual(
      calls.find((x) => Array.isArray(x)),
      ["create", "uid-A", "legacy_single_owner"],
    );
  }

  // 6. legacy wrong-owner rejection
  {
    const { deps } = makeDeps({
      legacy: {
        kind: "single",
        uid: "uid-B",
      },
    });

    await assert.rejects(
      () =>
        assertReceiptOwnershipWithDependencies(
          "uid-A",
          result,
          deps,
        ),
      (error) =>
        error?.statusCode === 409 ||
        error?.status === 409,
    );
  }

  // 7. ambiguous legacy ownership -> fail closed
  {
    const { deps } = makeDeps({
      legacy: {
        kind: "conflict",
        uids: ["uid-A", "uid-B"],
      },
    });

    await assert.rejects(
      () =>
        assertReceiptOwnershipWithDependencies(
          "uid-A",
          result,
          deps,
        ),
      (error) =>
        error?.statusCode === 409 ||
        error?.status === 409,
    );
  }

  // 8. concurrent race won by same UID -> allow
  {
    const { deps } = makeDeps({
      createResult: "already_exists",
      racedOwner: {
        kind: "active",
        ownerUid: "uid-A",
        updateTime: "t-race-a",
      },
    });

    await assertReceiptOwnershipWithDependencies(
      "uid-A",
      result,
      deps,
    );
  }

  // 9. concurrent race won by different UID -> reject
  {
    const { deps } = makeDeps({
      createResult: "already_exists",
      racedOwner: {
        kind: "active",
        ownerUid: "uid-B",
        updateTime: "t-race-b",
      },
    });

    await assert.rejects(
      () =>
        assertReceiptOwnershipWithDependencies(
          "uid-A",
          result,
          deps,
        ),
      (error) =>
        error?.statusCode === 409 ||
        error?.status === 409,
    );
  }
});
