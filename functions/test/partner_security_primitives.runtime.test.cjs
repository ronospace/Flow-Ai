"use strict";

const test = require("node:test");
const assert = require("node:assert/strict");
const {Timestamp} = require("firebase-admin/firestore");

const {
  timestampToMillis,
  getInviteOwnerUid,
  getInviteRecipientEmail,
  getInviteExpiryMillis,
  escapeHtml,
} = require("../lib/partner_security_primitives.js");

const ISO_TIMESTAMP = "2026-07-20T23:15:34.000Z";
const ISO_TIMESTAMP_MILLIS = 1784589334000;

test("required production functions are exported", () => {
  for (const callable of [
    timestampToMillis,
    getInviteOwnerUid,
    getInviteRecipientEmail,
    getInviteExpiryMillis,
    escapeHtml,
  ]) {
    assert.equal(typeof callable, "function");
  }
});

test("owner UID uses primary key and trims whitespace", () => {
  assert.equal(
    getInviteOwnerUid({
      ownerUid: "  owner-primary  ",
      fromUid: "owner-secondary",
      inviterId: "owner-tertiary",
    }),
    "owner-primary",
  );
});

test("owner UID falls back to fromUid", () => {
  assert.equal(
    getInviteOwnerUid({
      ownerUid: " ",
      fromUid: "  owner-secondary  ",
    }),
    "owner-secondary",
  );
});

test("owner UID falls back to inviterId", () => {
  assert.equal(
    getInviteOwnerUid({
      ownerUid: null,
      fromUid: 42,
      inviterId: " owner-tertiary ",
    }),
    "owner-tertiary",
  );
});

test("owner UID rejects unsupported field types", () => {
  assert.equal(
    getInviteOwnerUid({
      ownerUid: 42,
      fromUid: false,
      inviterId: null,
    }),
    "",
  );
});

test("recipient email uses primary key and normalizes case", () => {
  assert.equal(
    getInviteRecipientEmail({
      recipientEmail: " User@Example.Invalid ",
      toEmail: "second@example.invalid",
    }),
    "user@example.invalid",
  );
});

test("recipient email falls back to toEmail", () => {
  assert.equal(
    getInviteRecipientEmail({
      recipientEmail: " ",
      toEmail: " SECOND@EXAMPLE.INVALID ",
    }),
    "second@example.invalid",
  );
});

test("recipient email falls back to inviteeEmail", () => {
  assert.equal(
    getInviteRecipientEmail({
      recipientEmail: null,
      toEmail: 7,
      inviteeEmail: " THIRD@EXAMPLE.INVALID ",
    }),
    "third@example.invalid",
  );
});

test("recipient email rejects unsupported field types", () => {
  assert.equal(
    getInviteRecipientEmail({
      recipientEmail: false,
      toEmail: 9,
      inviteeEmail: null,
    }),
    "",
  );
});

test("timestamp conversion supports Firestore Timestamp", () => {
  assert.equal(
    timestampToMillis(
      Timestamp.fromMillis(1700000000123),
    ),
    1700000000123,
  );
});

test("timestamp conversion supports Date", () => {
  assert.equal(
    timestampToMillis(new Date(ISO_TIMESTAMP)),
    ISO_TIMESTAMP_MILLIS,
  );
});

test("timestamp conversion supports finite numbers", () => {
  assert.equal(timestampToMillis(-1000), -1000);
});

test("timestamp conversion rejects non-finite numbers", () => {
  assert.equal(
    timestampToMillis(Number.POSITIVE_INFINITY),
    null,
  );
});

test("timestamp conversion supports explicit ISO strings", () => {
  assert.equal(
    timestampToMillis(ISO_TIMESTAMP),
    ISO_TIMESTAMP_MILLIS,
  );
});

test("timestamp conversion rejects invalid strings", () => {
  assert.equal(
    timestampToMillis("not-a-timestamp"),
    null,
  );
});

test("timestamp conversion supports toMillis objects", () => {
  const value = {
    marker: 91,
    toMillis() {
      assert.equal(this.marker, 91);
      return 1700000000456;
    },
  };

  assert.equal(
    timestampToMillis(value),
    1700000000456,
  );
});

test("timestamp conversion rejects nonnumeric toMillis results", () => {
  assert.equal(
    timestampToMillis({
      toMillis() {
        return "1700000000456";
      },
    }),
    null,
  );
});

test("timestamp conversion supports seconds", () => {
  assert.equal(
    timestampToMillis({seconds: 1700000000}),
    1700000000000,
  );
});

test("timestamp conversion supports legacy _seconds", () => {
  assert.equal(
    timestampToMillis({_seconds: 1700000001}),
    1700000001000,
  );
});

test("timestamp conversion returns null for null", () => {
  assert.equal(timestampToMillis(null), null);
});

test("invite expiry preserves primary-key precedence", () => {
  assert.equal(
    getInviteExpiryMillis({
      expiresAt: 0,
      expiry: 1700000000001,
      expiresAtMillis: 1700000000002,
    }),
    0,
  );
});

test("invite expiry uses expiresAtMillis fallback", () => {
  assert.equal(
    getInviteExpiryMillis({
      expiresAt: null,
      expiry: undefined,
      expiresAtMillis: 1700000000002,
    }),
    1700000000002,
  );
});

test("invite expiry delegates ISO conversion", () => {
  assert.equal(
    getInviteExpiryMillis({
      expiresAt: ISO_TIMESTAMP,
    }),
    ISO_TIMESTAMP_MILLIS,
  );
});

test("HTML escaping covers every special character", () => {
  assert.equal(
    escapeHtml(`&<>"'`),
    "&amp;&lt;&gt;&quot;&#39;",
  );
});

test("HTML escaping escapes existing entities", () => {
  assert.equal(
    escapeHtml("&amp;"),
    "&amp;amp;",
  );
});
