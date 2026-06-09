/* eslint-disable max-len */
import {Timestamp} from "firebase-admin/firestore";
import {HttpsError} from "firebase-functions/v2/https";

export type JsonMap = Record<string, unknown>;

const INVITE_CODE_PATTERN = /^[A-HJ-NP-Z2-9]{6}$/;
const EMAIL_PATTERN = /^[^\s@]+@[^\s@]+\.[^\s@]{2,}$/;

export const MAX_EMAIL_LENGTH = 254;
export const MAX_MESSAGE_LENGTH = 500;
export const MAX_NAME_LENGTH = 120;
export const MAX_LINK_LENGTH = 2048;
export const MAX_INVITE_LIFETIME_MS =
  14 * 24 * 60 * 60 * 1000;
export const MIN_INVITE_LIFETIME_MS =
  60 * 1000;

/**
 * Validates callable request data as a plain object.
 * @param {unknown} value Raw callable request data.
 * @return {Object} Validated request data.
 */
export function requireRequestData(
  value: unknown,
): JsonMap {
  if (
    value == null ||
    typeof value !== "object" ||
    Array.isArray(value)
  ) {
    throw new HttpsError(
      "invalid-argument",
      "Invalid request payload.",
    );
  }

  return value as JsonMap;
}

/**
 * Returns the authenticated Firebase user identifier.
 * @param {unknown} auth Callable authentication context.
 * @return {string} Authenticated Firebase UID.
 */
export function requireAuthenticatedUid(
  auth: unknown,
): string {
  if (
    auth == null ||
    typeof auth !== "object"
  ) {
    throw new HttpsError(
      "unauthenticated",
      "Authentication is required.",
    );
  }

  const rawUid = (auth as {uid?: unknown}).uid;

  if (
    typeof rawUid !== "string" ||
    !rawUid.trim()
  ) {
    throw new HttpsError(
      "unauthenticated",
      "Authentication is required.",
    );
  }

  return rawUid.trim();
}

/**
 * Reads and bounds an optional string field.
 * @param {Object} data Validated request data.
 * @param {string} key Field name.
 * @param {number} maximumLength Maximum permitted length.
 * @return {string} Trimmed value or an empty string.
 */
export function optionalBoundedString(
  data: JsonMap,
  key: string,
  maximumLength: number,
): string {
  const raw = data[key];

  if (raw == null) {
    return "";
  }

  if (typeof raw !== "string") {
    throw new HttpsError(
      "invalid-argument",
      `${key} must be a string.`,
    );
  }

  const value = raw.trim();

  if (value.length > maximumLength) {
    throw new HttpsError(
      "invalid-argument",
      `${key} is too long.`,
    );
  }

  return value;
}

/**
 * Reads, bounds, and requires a string field.
 * @param {Object} data Validated request data.
 * @param {string} key Field name.
 * @param {number} maximumLength Maximum permitted length.
 * @return {string} Validated non-empty value.
 */
export function requiredBoundedString(
  data: JsonMap,
  key: string,
  maximumLength: number,
): string {
  const value = optionalBoundedString(
    data,
    key,
    maximumLength,
  );

  if (!value) {
    throw new HttpsError(
      "invalid-argument",
      `${key} is required.`,
    );
  }

  return value;
}

/**
 * Normalizes the verified invitation-code format.
 * @param {string} value Raw invitation code.
 * @return {string} Normalized invitation code.
 */
export function normalizeInvitationCode(
  value: string,
): string {
  const code = value.trim().toUpperCase();

  if (!INVITE_CODE_PATTERN.test(code)) {
    throw new HttpsError(
      "invalid-argument",
      "Invitation code is invalid.",
    );
  }

  return code;
}

/**
 * Normalizes and validates an email address.
 * @param {string} value Raw email address.
 * @param {boolean} isRequired Whether an address is required.
 * @return {string} Normalized email address.
 */
export function normalizeEmailAddress(
  value: string,
  isRequired = true,
): string {
  const email = value.trim().toLowerCase();

  if (!email && !isRequired) {
    return "";
  }

  if (
    !email ||
    email.length > MAX_EMAIL_LENGTH ||
    !EMAIL_PATTERN.test(email)
  ) {
    throw new HttpsError(
      "invalid-argument",
      "Email address is invalid.",
    );
  }

  return email;
}

/**
 * Validates an HTTPS invitation link and its code.
 * @param {string} value Raw invitation link.
 * @param {string} invitationCode Normalized invitation code.
 * @return {string} Canonical HTTPS invitation URL.
 */
export function normalizeHttpsInvitationLink(
  value: string,
  invitationCode: string,
): string {
  let parsed: URL;

  try {
    parsed = new URL(value);
  } catch {
    throw new HttpsError(
      "invalid-argument",
      "Invitation link is invalid.",
    );
  }

  if (
    parsed.protocol !== "https:" ||
    parsed.username ||
    parsed.password ||
    !parsed.hostname
  ) {
    throw new HttpsError(
      "invalid-argument",
      "Invitation link must use HTTPS.",
    );
  }

  if (
    !parsed
      .toString()
      .toUpperCase()
      .includes(invitationCode.toUpperCase())
  ) {
    throw new HttpsError(
      "invalid-argument",
      "Invitation link does not match the invitation code.",
    );
  }

  return parsed.toString();
}

/**
 * Validates the permitted expiry window.
 * @param {Object} data Validated request data.
 * @param {number} nowMillis Current timestamp.
 * @return {number} Validated expiry timestamp.
 */
export function requireInviteExpiryMillis(
  data: JsonMap,
  nowMillis = Date.now(),
): number {
  const raw = data.expiresAtMillis;

  if (
    typeof raw !== "number" ||
    !Number.isSafeInteger(raw)
  ) {
    throw new HttpsError(
      "invalid-argument",
      "expiresAtMillis must be an integer timestamp.",
    );
  }

  if (
    raw < nowMillis + MIN_INVITE_LIFETIME_MS ||
    raw > nowMillis + MAX_INVITE_LIFETIME_MS
  ) {
    throw new HttpsError(
      "invalid-argument",
      "Invitation expiry is outside the permitted range.",
    );
  }

  return raw;
}

/**
 * Converts supported timestamps to milliseconds.
 * @param {unknown} value Timestamp value.
 * @return {*} Milliseconds or null when unsupported.
 */
export function timestampToMillis(
  value: unknown,
): number | null {
  if (value instanceof Timestamp) {
    return value.toMillis();
  }

  if (value instanceof Date) {
    return value.getTime();
  }

  if (
    typeof value === "number" &&
    Number.isFinite(value)
  ) {
    return value;
  }

  if (typeof value === "string") {
    const parsed = Date.parse(value);
    return Number.isNaN(parsed) ? null : parsed;
  }

  if (
    value != null &&
    typeof value === "object"
  ) {
    const candidate = value as {
      toMillis?: unknown;
      seconds?: unknown;
      _seconds?: unknown;
    };

    if (typeof candidate.toMillis === "function") {
      const result = (
        candidate.toMillis as () => unknown
      ).call(value);

      return typeof result === "number" ?
        result :
        null;
    }

    const seconds =
      typeof candidate.seconds === "number" ?
        candidate.seconds :
        candidate._seconds;

    if (typeof seconds === "number") {
      return seconds * 1000;
    }
  }

  return null;
}

/**
 * Returns the invitation owner UID.
 * @param {Object} data Invitation document data.
 * @return {string} Owner UID or an empty string.
 */
export function getInviteOwnerUid(
  data: JsonMap,
): string {
  for (
    const key of [
      "ownerUid",
      "fromUid",
      "inviterId",
    ]
  ) {
    const value = data[key];

    if (
      typeof value === "string" &&
      value.trim()
    ) {
      return value.trim();
    }
  }

  return "";
}

/**
 * Returns the invitation recipient email.
 * @param {Object} data Invitation document data.
 * @return {string} Recipient email or an empty string.
 */
export function getInviteRecipientEmail(
  data: JsonMap,
): string {
  for (
    const key of [
      "recipientEmail",
      "toEmail",
      "inviteeEmail",
    ]
  ) {
    const value = data[key];

    if (
      typeof value === "string" &&
      value.trim()
    ) {
      return value.trim().toLowerCase();
    }
  }

  return "";
}

/**
 * Returns the invitation expiry timestamp.
 * @param {Object} data Invitation document data.
 * @return {*} Expiry milliseconds or null.
 */
export function getInviteExpiryMillis(
  data: JsonMap,
): number | null {
  return timestampToMillis(
    data.expiresAt ??
    data.expiry ??
    data.expiresAtMillis,
  );
}

/**
 * Rejects inactive or expired invitations.
 * @param {Object} data Invitation document data.
 * @param {number} nowMillis Current timestamp.
 * @return {void} Nothing.
 */
export function assertInviteIsActive(
  data: JsonMap,
  nowMillis = Date.now(),
): void {
  const status =
    typeof data.status === "string" ?
      data.status.toLowerCase() :
      "active";

  if (
    [
      "accepted",
      "consumed",
      "revoked",
      "expired",
      "cancelled",
    ].includes(status)
  ) {
    throw new HttpsError(
      "failed-precondition",
      "Invitation is no longer active.",
    );
  }

  const expiry = getInviteExpiryMillis(data);

  if (expiry == null) {
    throw new HttpsError(
      "failed-precondition",
      "Invitation expiry is unavailable.",
    );
  }

  if (expiry <= nowMillis) {
    throw new HttpsError(
      "failed-precondition",
      "Invitation has expired.",
    );
  }
}

/**
 * Escapes user-controlled text for HTML.
 * @param {string} value Raw text.
 * @return {string} HTML-safe text.
 */
export function escapeHtml(
  value: string,
): string {
  return value
    .replace(/&/g, "&amp;")
    .replace(/</g, "&lt;")
    .replace(/>/g, "&gt;")
    .replace(/"/g, "&quot;")
    .replace(/'/g, "&#39;");
}
