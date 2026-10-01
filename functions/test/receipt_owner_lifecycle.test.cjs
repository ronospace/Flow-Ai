const assert = require("node:assert/strict");
const test = require("node:test");

process.env.GCLOUD_PROJECT =
  process.env.GCLOUD_PROJECT ||
  "flowai-demo-project";

test(
  "receipt owner deletion fields are explicit and fail closed",
  async () => {
    const mod = require(
      "../lib/receipt_owner_lifecycle.js"
    );

    const deletedAt = {
      sentinel: "server-time",
    };

    const fields =
      mod.buildReceiptOwnerDeletionFields(
        "uid-A",
        deletedAt,
      );

    assert.deepEqual(
      fields,
      {
        ownerStatus: "auth_deleted",
        deletedOwnerUid: "uid-A",
        deletedAt,
        schemaVersion: 2,
      },
    );

    assert.throws(
      () =>
        mod.buildReceiptOwnerDeletionFields(
          "   ",
          deletedAt,
        ),
      /receipt_owner_deleted_uid_required/,
    );
  },
);

test(
  "receipt owner deletion transition skips stale and transferred owners",
  async () => {
    const mod = require(
      "../lib/receipt_owner_lifecycle.js"
    );

    assert.equal(
      mod.shouldMarkReceiptOwnerAuthDeleted(
        {
          ownerUid: "uid-A",
        },
        "uid-A",
      ),
      true,
    );

    assert.equal(
      mod.shouldMarkReceiptOwnerAuthDeleted(
        {
          ownerUid: "uid-B",
        },
        "uid-A",
      ),
      false,
    );

    assert.equal(
      mod.shouldMarkReceiptOwnerAuthDeleted(
        {
          ownerUid: "uid-A",
          ownerStatus: "auth_deleted",
          deletedOwnerUid: "uid-A",
        },
        "uid-A",
      ),
      false,
    );

    assert.equal(
      mod.shouldMarkReceiptOwnerAuthDeleted(
        {
          ownerUid: "uid-A",
          ownerStatus: "auth_deleted",
          deletedOwnerUid: "uid-B",
        },
        "uid-A",
      ),
      true,
    );
  },
);

test(
  "receipt owner deletion transaction rereads ownership before update",
  () => {
    const fs = require("node:fs");
    const path = require("node:path");

    const source = fs.readFileSync(
      path.join(
        __dirname,
        "../src/receipt_owner_lifecycle.ts",
      ),
      "utf8",
    );

    assert.match(
      source,
      /db\.runTransaction\(/,
    );

    assert.match(
      source,
      /transaction\.get\(document\.ref\)/,
    );

    assert.match(
      source,
      /if \(!current\.exists\)/,
    );

    assert.match(
      source,
      /if \(data === undefined\)/,
    );

    assert.match(
      source,
      /shouldMarkReceiptOwnerAuthDeleted\([\s\S]*data,[\s\S]*uid/,
    );

    assert.match(
      source,
      /transaction\.update\([\s\S]*document\.ref/,
    );

    assert.doesNotMatch(
      source,
      /db\.batch\(\)/,
    );
  },
);

test(
  "auth deletion trigger has retry-enabled Firebase Auth semantics",
  async () => {
    const mod = require(
      "../lib/receipt_owner_lifecycle.js"
    );

    const trigger =
      mod.releaseReceiptOwnersOnAuthDelete
        .__trigger;

    const endpoint =
      mod.releaseReceiptOwnersOnAuthDelete
        .__endpoint;

    assert.equal(
      trigger?.eventTrigger?.eventType,
      "providers/firebase.auth/eventTypes/user.delete",
    );

    assert.deepEqual(
      trigger?.failurePolicy?.retry,
      {},
    );

    assert.equal(
      endpoint?.eventTrigger?.retry,
      true,
    );
  },
);
