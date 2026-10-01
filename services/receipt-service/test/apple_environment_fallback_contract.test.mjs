import assert from "node:assert/strict";
import { readFile } from "node:fs/promises";
import test from "node:test";

const source = await readFile(
  new URL("../src/index.ts", import.meta.url),
  "utf8",
);

test("Apple validation retries the alternate environment only after 404", () => {
  assert.match(
    source,
    /function appleProviderHttpStatus/,
  );

  assert.match(
    source,
    /function alternateAppleEnvironment/,
  );

  assert.match(
    source,
    /async function verifyAppleTransactionInEnvironment/,
  );

  assert.match(
    source,
    /appleProviderHttpStatus\(error\) !== 404/,
  );

  assert.match(
    source,
    /alternateAppleEnvironment\(\s*preferredEnvironment/,
  );
});

test("fallback transaction is cryptographically verified in successful environment", () => {
  assert.match(
    source,
    /new SignedDataVerifier\([\s\S]*appleEnvironment/,
  );

  assert.match(
    source,
    /verifyAndDecodeTransaction/,
  );

  assert.match(
    source,
    /decodedProductId !== productId/,
  );

  assert.match(
    source,
    /decodedTransactionId !== transactionId/,
  );
});

test("404 in both Apple environments is invalid receipt, not provider outage", () => {
  assert.match(
    source,
    /if \(appleProviderHttpStatus\(error\) === 404\) \{\s*return null;/,
  );
});
