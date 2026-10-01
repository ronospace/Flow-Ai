import {
  AppStoreServerAPIClient,
  Environment,
  SignedDataVerifier,
  Status,
} from "@apple/app-store-server-library";
import {
  createHash,
} from "node:crypto";
import {
  createServer,
} from "node:http";
import type {
  IncomingHttpHeaders,
  IncomingMessage,
  Server,
  ServerResponse,
} from "node:http";
import {
  pathToFileURL,
} from "node:url";
import {
  createRemoteJWKSet,
  jwtVerify,
} from "jose";

export const runtimeArchitecture = "minimal-cloud-run";

type JsonRecord = Record<string, unknown>;

type Platform = "ios" | "android";

type LifecycleStatus =
  | "active"
  | "grace_period"
  | "paid_through_cancellation";

type ProviderValidationResult = {
  platform: Platform;
  provider: "apple" | "google";
  productId: string;
  transactionId: string;
  originalTransactionId: string;
  expirationDate: Date;
  lifecycleStatus?: LifecycleStatus;
};

type CachedAccessToken = {
  value: string;
  expiresAtMillis: number;
};

type GoogleSubscriptionLineItem = {
  expiryTime?: unknown;
};

const maximumBodyBytes = 64 * 1024;

const firebaseJwks = createRemoteJWKSet(
  new URL(
    "https://www.googleapis.com/service_accounts/v1/jwk/" +
      "securetoken@system.gserviceaccount.com",
  ),
);

const allowedProducts = new Set([
  "flow_ai_premium_monthly",
  "flow_ai_premium_yearly",
]);

const allowedAppleEnvironments = new Set([
  "production",
  "sandbox",
]);


const androidPublisherScope =
  "https://www.googleapis.com/auth/androidpublisher";

const androidPublisherBaseUrl =
  "https://androidpublisher.googleapis.com/androidpublisher/v3";

const firestoreBaseUrl =
  "https://firestore.googleapis.com/v1";

let runtimeAccessTokenCache: CachedAccessToken | null = null;
let playAccessTokenCache: CachedAccessToken | null = null;

class HttpError extends Error {
  readonly statusCode: number;
  readonly safeCode: string;

  constructor(statusCode: number, safeCode: string) {
    super(safeCode);
    this.name = "HttpError";
    this.statusCode = statusCode;
    this.safeCode = safeCode;
  }
}

class ProviderConfigurationError extends Error {
  constructor() {
    super("provider_configuration_error");
    this.name = "ProviderConfigurationError";
  }
}

function sendJson(
  response: ServerResponse,
  statusCode: number,
  body: JsonRecord,
): void {
  response.writeHead(statusCode, {
    "Cache-Control": "no-store",
    "Content-Type": "application/json; charset=utf-8",
    "X-Content-Type-Options": "nosniff",
  });
  response.end(JSON.stringify(body));
}


function readRecord(value: unknown): JsonRecord | null {
  if (
    value === null ||
    typeof value !== "object" ||
    Array.isArray(value)
  ) {
    return null;
  }

  return value as JsonRecord;
}

function readNonEmptyString(value: unknown): string | null {
  if (typeof value !== "string") {
    return null;
  }

  const trimmed = value.trim();
  return trimmed.length > 0 ? trimmed : null;
}

function readFiniteNumber(value: unknown): number | null {
  if (
    typeof value !== "number" ||
    !Number.isFinite(value)
  ) {
    return null;
  }

  return value;
}

function readIntegerValue(value: unknown): number | null {
  if (
    typeof value === "number" &&
    Number.isSafeInteger(value)
  ) {
    return value;
  }

  if (typeof value === "string") {
    const parsed = Number.parseInt(value, 10);
    return Number.isSafeInteger(parsed) ? parsed : null;
  }

  return null;
}

function requiredString(
  record: JsonRecord,
  key: string,
  maximumLength: number,
): string {
  const value = readNonEmptyString(record[key]);

  if (
    value === null ||
    value.length > maximumLength
  ) {
    throw new HttpError(400, "invalid_request");
  }

  return value;
}

function requiredEnvironment(name: string): string {
  const value = readNonEmptyString(process.env[name]);

  if (value === null) {
    throw new ProviderConfigurationError();
  }

  return value;
}

function normalizePem(value: string): string {
  return value.replace(/\\n/g, "\n");
}

function parseAppleRootCertificates(value: string): Buffer[] {
  const matches = normalizePem(value).match(
    /-----BEGIN ' + 'CERTIFICATE-----[\s\S]+?-----END CERTIFICATE-----/g,
  ) ?? [];

  if (matches.length === 0) {
    throw new ProviderConfigurationError();
  }

  return matches.map((certificate) => Buffer.from(certificate));
}

function toAppleEnvironment(value: string): Environment {
  return value === "production" ?
    Environment.PRODUCTION :
    Environment.SANDBOX;
}

function hashIdentifier(value: string): string {
  return createHash("sha256").update(value).digest("hex");
}

function projectId(): string {
  return (
    readNonEmptyString(process.env.GOOGLE_CLOUD_PROJECT) ??
    readNonEmptyString(process.env.GCLOUD_PROJECT) ??
    readNonEmptyString(process.env.FLOW_AI_PROJECT_ID) ??
    (() => {
      throw new ProviderConfigurationError();
    })()
  );
}

export function extractBearerToken(
  value: IncomingHttpHeaders["authorization"],
): string | null {
  if (
    typeof value !== "string" ||
    !value.startsWith("Bearer ")
  ) {
    return null;
  }

  const token = value.slice("Bearer ".length).trim();
  return token.length > 0 ? token : null;
}

async function requireFirebaseUid(
  request: IncomingMessage,
): Promise<string> {
  const token = extractBearerToken(request.headers.authorization);

  if (token === null) {
    throw new HttpError(401, "authentication_required");
  }

  const firebaseProjectId = projectId();

  try {
    const result = await jwtVerify(token, firebaseJwks, {
      algorithms: [
        "RS256",
      ],
      audience: firebaseProjectId,
      issuer: `https://securetoken.google.com/${firebaseProjectId}`,
    });

    const uid = readNonEmptyString(result.payload.sub);

    if (uid === null || uid.length > 128) {
      throw new HttpError(401, "invalid_authentication");
    }

    return uid;
  } catch (error) {
    if (error instanceof HttpError) {
      throw error;
    }

    throw new HttpError(401, "invalid_authentication");
  }
}

async function readJsonBody(
  request: IncomingMessage,
): Promise<JsonRecord> {
  const contentType = request.headers["content-type"];

  if (
    typeof contentType !== "string" ||
    !contentType.toLowerCase().startsWith("application/json")
  ) {
    throw new HttpError(415, "json_content_type_required");
  }

  const chunks: Buffer[] = [];
  let totalBytes = 0;

  for await (const chunk of request) {
    const buffer = Buffer.isBuffer(chunk) ?
      chunk :
      Buffer.from(chunk);

    totalBytes += buffer.length;

    if (totalBytes > maximumBodyBytes) {
      throw new HttpError(413, "request_too_large");
    }

    chunks.push(buffer);
  }

  if (chunks.length === 0) {
    throw new HttpError(400, "invalid_request");
  }

  try {
    const parsed = JSON.parse(
      Buffer.concat(chunks).toString("utf8"),
    ) as unknown;

    const record = readRecord(parsed);

    if (record === null) {
      throw new HttpError(400, "invalid_request");
    }

    return record;
  } catch (error) {
    if (error instanceof HttpError) {
      throw error;
    }

    throw new HttpError(400, "invalid_json");
  }
}

async function runtimeAccessToken(): Promise<string> {
  const now = Date.now();

  if (
    runtimeAccessTokenCache !== null &&
    runtimeAccessTokenCache.expiresAtMillis > now + 30_000
  ) {
    return runtimeAccessTokenCache.value;
  }

  const metadataHost =
    readNonEmptyString(process.env.GCE_METADATA_HOST) ??
    "metadata.google.internal";

  const response = await fetch(
    `http://${metadataHost}/computeMetadata/v1/instance/` +
      "service-accounts/default/token",
    {
      headers: {
        "Metadata-Flavor": "Google",
      },
    },
  );

  if (!response.ok) {
    throw new Error(`metadata_token_failed_${response.status}`);
  }

  const data = readRecord(await response.json());
  const token = readNonEmptyString(data?.access_token);
  const expiresInSeconds = readFiniteNumber(data?.expires_in) ?? 300;

  if (token === null) {
    throw new Error("metadata_token_missing");
  }

  runtimeAccessTokenCache = {
    value: token,
    expiresAtMillis:
      now + Math.max(30, expiresInSeconds - 60) * 1000,
  };

  return token;
}

async function googlePlayAccessToken(): Promise<string> {
  const now = Date.now();

  if (
    playAccessTokenCache !== null &&
    playAccessTokenCache.expiresAtMillis > now + 30_000
  ) {
    return playAccessTokenCache.value;
  }

  const targetServiceAccount = requiredEnvironment(
    "FLOW_AI_GOOGLE_PLAY_SERVICE_ACCOUNT",
  );

  const sourceToken = await runtimeAccessToken();

  const url =
    "https://iamcredentials.googleapis.com/v1/projects/-/" +
    `serviceAccounts/${encodeURIComponent(targetServiceAccount)}` +
    ":generateAccessToken";

  const response = await fetch(url, {
    method: "POST",
    headers: {
      Authorization: `Bearer ${sourceToken}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({
      scope: [
        androidPublisherScope,
      ],
      lifetime: "900s",
    }),
  });

  if (!response.ok) {
    throw new Error(
      `play_token_generation_failed_${response.status}`,
    );
  }

  const data = readRecord(await response.json());
  const accessToken = readNonEmptyString(data?.accessToken);
  const expireTime = readNonEmptyString(data?.expireTime);
  const parsedExpiry = expireTime === null ?
    Number.NaN :
    Date.parse(expireTime);

  if (accessToken === null) {
    throw new Error("play_token_generation_missing_token");
  }

  playAccessTokenCache = {
    value: accessToken,
    expiresAtMillis: Number.isFinite(parsedExpiry) ?
      parsedExpiry :
      now + 10 * 60 * 1000,
  };

  return accessToken;
}

function entitlementDocumentUrl(
  uid: string,
  subscriptionId: string,
): string {
  const firebaseProjectId = projectId();

  return [
    firestoreBaseUrl,
    "projects",
    encodeURIComponent(firebaseProjectId),
    "databases",
    "(default)",
    "documents",
    "premiumEntitlements",
    encodeURIComponent(uid),
    "subscriptions",
    encodeURIComponent(subscriptionId),
  ].join("/");
}

function firestoreFields(
  uid: string,
  result: ProviderValidationResult,
): JsonRecord {
  const now = new Date().toISOString();
  const expiration = result.expirationDate.toISOString();

  return {
    active: {
      booleanValue: result.expirationDate.getTime() > Date.now(),
    },
    expiresAt: {
      timestampValue: expiration,
    },
    expiresAtMillis: {
      integerValue: String(result.expirationDate.getTime()),
    },
    originalTransactionId: {
      stringValue: result.originalTransactionId,
    },
    lifecycleStatus: {
      stringValue: result.lifecycleStatus,
    },
    platform: {
      stringValue: result.platform,
    },
    productId: {
      stringValue: result.productId,
    },
    provider: {
      stringValue: result.provider,
    },
    transactionId: {
      stringValue: result.transactionId,
    },
    updatedAt: {
      timestampValue: now,
    },
    userId: {
      stringValue: uid,
    },
    validatedAt: {
      timestampValue: now,
    },
  };
}


type ReceiptOwnershipSource =
  | "first_verified_claim"
  | "legacy_single_owner"
  | "deleted_owner_transfer";

type ReceiptOwnerState =
  | {
      kind: "active";
      ownerUid: string;
      updateTime: string;
    }
  | {
      kind: "auth_deleted";
      ownerUid: string;
      deletedOwnerUid: string;
      updateTime: string;
    };

type LegacyReceiptOwnerState =
  | { kind: "none" }
  | { kind: "single"; uid: string }
  | { kind: "conflict"; uids: string[] };

function receiptOwnershipKey(
  platform: ProviderValidationResult["platform"],
  originalTransactionId: string,
): string {
  return createHash("sha256")
    .update(
      `${platform}:${originalTransactionId}`,
      "utf8",
    )
    .digest("hex");
}

function receiptOwnerDocumentUrl(
  ownershipKey: string,
): string {
  return [
    "https://firestore.googleapis.com/v1/projects",
    encodeURIComponent(projectId()),
    "databases/(default)/documents",
    `premiumReceiptOwners/${encodeURIComponent(ownershipKey)}`,
  ].join("/");
}

function receiptOwnerCreateUrl(
  ownershipKey: string,
): string {
  return [
    "https://firestore.googleapis.com/v1/projects",
    encodeURIComponent(projectId()),
    "databases/(default)/documents/premiumReceiptOwners",
    `?documentId=${encodeURIComponent(ownershipKey)}`,
  ].join("/");
}


function receiptOwnerUpdateUrl(
  ownershipKey: string,
  updateTime: string,
): string {
  const query = new URLSearchParams();

  for (const field of [
    "ownerUid",
    "ownerStatus",
    "ownershipSource",
    "schemaVersion",
    "previousOwnerUid",
    "deletedOwnerUid",
    "transferredAt",
  ]) {
    query.append("updateMask.fieldPaths", field);
  }

  query.set(
    "currentDocument.updateTime",
    updateTime,
  );

  return `${receiptOwnerDocumentUrl(ownershipKey)}?${query.toString()}`;
}

function firestoreStringField(
  fields:
    | Record<string, { stringValue?: string }>
    | undefined,
  field: string,
): string | null {
  const value=fields?.[field]?.stringValue;

  return typeof value === "string" &&
      value.length > 0
    ? value
    : null;
}

async function readReceiptOwner(
  token: string,
  ownershipKey: string,
): Promise<ReceiptOwnerState | null> {
  const response=await fetch(
    receiptOwnerDocumentUrl(ownershipKey),
    {
      headers: {
        Authorization: `Bearer ${token}`,
      },
    },
  );

  if (response.status === 404) {
    return null;
  }

  if (!response.ok) {
    throw new Error(
      `receipt owner read failed: ${response.status} ${await response.text()}`,
    );
  }

  const document=(await response.json()) as {
    fields?: Record<
      string,
      { stringValue?: string }
    >;
    updateTime?: string;
  };

  const ownerUid=firestoreStringField(
    document.fields,
    "ownerUid",
  );

  if (ownerUid === null) {
    throw new Error(
      "receipt owner document missing ownerUid",
    );
  }

  const updateTime =
    typeof document.updateTime === "string" &&
    document.updateTime.length > 0
      ? document.updateTime
      : null;

  if (updateTime === null) {
    throw new Error(
      "receipt owner document missing updateTime",
    );
  }

  const ownerStatus=firestoreStringField(
    document.fields,
    "ownerStatus",
  );

  // Schema-v1 / historical canonical owner documents have no
  // ownerStatus. They remain ACTIVE by default.
  if (
    ownerStatus === null ||
    ownerStatus === "active"
  ) {
    return {
      kind: "active",
      ownerUid,
      updateTime,
    };
  }

  if (ownerStatus === "auth_deleted") {
    const deletedOwnerUid=firestoreStringField(
      document.fields,
      "deletedOwnerUid",
    );

    if (
      deletedOwnerUid === null ||
      deletedOwnerUid !== ownerUid
    ) {
      throw new Error(
        "receipt owner auth_deleted invariant failed",
      );
    }

    return {
      kind: "auth_deleted",
      ownerUid,
      deletedOwnerUid,
      updateTime,
    };
  }

  throw new Error(
    "receipt owner status unsupported",
  );
}

async function queryLegacyReceiptOwners(
  token: string,
  result: ProviderValidationResult,
): Promise<LegacyReceiptOwnerState> {
  const url=[
    "https://firestore.googleapis.com/v1/projects",
    encodeURIComponent(projectId()),
    "databases/(default)/documents:runQuery",
  ].join("/");

  const response=await fetch(
    url,
    {
      method: "POST",
      headers: {
        Authorization: `Bearer ${token}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        structuredQuery: {
          from: [
            {
              collectionId: "subscriptions",
              allDescendants: true,
            },
          ],
          where: {
            fieldFilter: {
              field: {
                fieldPath:
                  "originalTransactionId",
              },
              op: "EQUAL",
              value: {
                stringValue:
                  result.originalTransactionId,
              },
            },
          },
        },
      }),
    },
  );

  if (!response.ok) {
    throw new Error(
      `legacy ownership query failed: ${response.status} ${await response.text()}`,
    );
  }

  const rows=(await response.json()) as Array<{
    document?: {
      fields?: Record<
        string,
        { stringValue?: string }
      >;
    };
  }>;

  const owners=new Set<string>();

  for (const row of rows) {
    const fields=row.document?.fields;

    const platform=firestoreStringField(
      fields,
      "platform",
    );

    // originalTransactionId can theoretically
    // collide across providers. Platform must match.
    if (platform !== result.platform) {
      continue;
    }

    const uid=
      firestoreStringField(
        fields,
        "userId",
      ) ??
      firestoreStringField(
        fields,
        "uid",
      );

    if (uid !== null) {
      owners.add(uid);
    }
  }

  if (owners.size === 0) {
    return { kind: "none" };
  }

  if (owners.size === 1) {
    const iterator=owners.values().next();

    if (
      iterator.done ||
      typeof iterator.value !== "string"
    ) {
      throw new Error(
        "legacy ownership invariant failed",
      );
    }

    return {
      kind: "single",
      uid: iterator.value,
    };
  }

  return {
    kind: "conflict",
    uids: Array.from(owners).sort(),
  };
}

async function createReceiptOwnerAtomically(
  token: string,
  ownershipKey: string,
  ownerUid: string,
  result: ProviderValidationResult,
  source: ReceiptOwnershipSource,
): Promise<"created" | "already_exists"> {
  const response=await fetch(
    receiptOwnerCreateUrl(ownershipKey),
    {
      method: "POST",
      headers: {
        Authorization: `Bearer ${token}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        fields: {
          ownerUid: {
            stringValue: ownerUid,
          },
          platform: {
            stringValue: result.platform,
          },
          originalTransactionId: {
            stringValue:
              result.originalTransactionId,
          },
          ownershipSource: {
            stringValue: source,
          },
          schemaVersion: {
            integerValue: "1",
          },
          createdAt: {
            timestampValue:
              new Date().toISOString(),
          },
        },
      }),
    },
  );

  if (response.ok) {
    return "created";
  }

  // Firestore create-only document semantics:
  // an existing deterministic document causes
  // a conflict rather than an overwrite.
  if (response.status === 409) {
    return "already_exists";
  }

  throw new Error(
    `receipt owner create failed: ${response.status} ${await response.text()}`,
  );
}

async function transferDeletedReceiptOwnerAtomically(
  token: string,
  ownershipKey: string,
  priorOwner: ReceiptOwnerState & {
    kind: "auth_deleted";
  },
  newOwnerUid: string,
): Promise<"transferred" | "precondition_failed"> {
  const response=await fetch(
    receiptOwnerUpdateUrl(
      ownershipKey,
      priorOwner.updateTime,
    ),
    {
      method: "PATCH",
      headers: {
        Authorization: `Bearer ${token}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        fields: {
          ownerUid: {
            stringValue: newOwnerUid,
          },
          ownerStatus: {
            stringValue: "active",
          },
          ownershipSource: {
            stringValue: "deleted_owner_transfer",
          },
          schemaVersion: {
            integerValue: "2",
          },
          previousOwnerUid: {
            stringValue: priorOwner.ownerUid,
          },
          deletedOwnerUid: {
            stringValue: priorOwner.deletedOwnerUid,
          },
          transferredAt: {
            timestampValue:
              new Date().toISOString(),
          },
        },
      }),
    },
  );

  if (response.ok) {
    return "transferred";
  }

  const body=await response.text();

  // Firestore REST may surface stale updateTime preconditions as
  // HTTP 409/412 or a FAILED_PRECONDITION response.
  if (
    response.status === 409 ||
    response.status === 412 ||
    (
      response.status === 400 &&
      body.includes("FAILED_PRECONDITION")
    )
  ) {
    return "precondition_failed";
  }

  throw new Error(
    `receipt owner transfer failed: ${response.status} ${body}`,
  );
}

type ReceiptOwnershipDependencies = {
  runtimeAccessToken: () => Promise<string>;
  readReceiptOwner: (
    token: string,
    ownershipKey: string,
  ) => Promise<ReceiptOwnerState | null>;
  queryLegacyReceiptOwners: (
    token: string,
    result: ProviderValidationResult,
  ) => Promise<LegacyReceiptOwnerState>;
  createReceiptOwnerAtomically: (
    token: string,
    ownershipKey: string,
    ownerUid: string,
    result: ProviderValidationResult,
    source: ReceiptOwnershipSource,
  ) => Promise<"created" | "already_exists">;
  transferDeletedReceiptOwnerAtomically: (
    token: string,
    ownershipKey: string,
    priorOwner: ReceiptOwnerState & {
      kind: "auth_deleted";
    },
    newOwnerUid: string,
  ) => Promise<"transferred" | "precondition_failed">;
};

export async function assertReceiptOwnershipWithDependencies(
  uid: string,
  result: ProviderValidationResult,
  dependencies: ReceiptOwnershipDependencies,
): Promise<void> {
  const token = await dependencies.runtimeAccessToken();

  const ownershipKey = receiptOwnershipKey(
    result.platform,
    result.originalTransactionId,
  );

  const existingOwner =
    await dependencies.readReceiptOwner(
      token,
      ownershipKey,
    );

  if (existingOwner !== null) {
    if (existingOwner.kind === "active") {
      if (existingOwner.ownerUid !== uid) {
        throw new HttpError(
          409,
          "receipt_owner_conflict",
        );
      }

      return;
    }

    if (existingOwner.ownerUid === uid) {
      throw new Error(
        "receipt owner deleted identity cannot reclaim itself",
      );
    }

    const transfer =
      await dependencies.transferDeletedReceiptOwnerAtomically(
        token,
        ownershipKey,
        existingOwner,
        uid,
      );

    if (transfer === "transferred") {
      return;
    }

    const racedOwner =
      await dependencies.readReceiptOwner(
        token,
        ownershipKey,
      );

    if (
      racedOwner !== null &&
      racedOwner.kind === "active" &&
      racedOwner.ownerUid === uid
    ) {
      return;
    }

    throw new HttpError(
      409,
      "receipt_owner_conflict",
    );
  }

  const legacy =
    await dependencies.queryLegacyReceiptOwners(
      token,
      result,
    );

  if (legacy.kind === "conflict") {
    throw new HttpError(
      409,
      "receipt_owner_conflict",
    );
  }

  const canonicalOwnerUid =
    legacy.kind === "single"
      ? legacy.uid
      : uid;

  const source: ReceiptOwnershipSource =
    legacy.kind === "single"
      ? "legacy_single_owner"
      : "first_verified_claim";

  const claim =
    await dependencies.createReceiptOwnerAtomically(
      token,
      ownershipKey,
      canonicalOwnerUid,
      result,
      source,
    );

  if (claim === "created") {
    if (canonicalOwnerUid !== uid) {
      throw new HttpError(
        409,
        "receipt_owner_conflict",
      );
    }

    return;
  }

  const racedOwner =
    await dependencies.readReceiptOwner(
      token,
      ownershipKey,
    );

  if (racedOwner === null) {
    throw new Error(
      "receipt ownership race invariant failed",
    );
  }

  if (
    racedOwner.kind !== "active" ||
    racedOwner.ownerUid !== uid
  ) {
    throw new HttpError(
      409,
      "receipt_owner_conflict",
    );
  }
}

async function assertReceiptOwnership(
  uid: string,
  result: ProviderValidationResult,
): Promise<void> {
  await assertReceiptOwnershipWithDependencies(
    uid,
    result,
    {
      runtimeAccessToken,
      readReceiptOwner,
      queryLegacyReceiptOwners,
      createReceiptOwnerAtomically,
      transferDeletedReceiptOwnerAtomically,
    },
  );
}

export async function persistAfterReceiptOwnership(
  uid: string,
  result: ProviderValidationResult,
  ownershipCheck: (
    uid: string,
    result: ProviderValidationResult,
  ) => Promise<void>,
  persist: (
    uid: string,
    result: ProviderValidationResult,
  ) => Promise<void>,
): Promise<void> {
  await ownershipCheck(uid, result);
  await persist(uid, result);
}

async function persistValidatedEntitlement(
  uid: string,
  result: ProviderValidationResult,
): Promise<void> {
  const token = await runtimeAccessToken();
  const response = await fetch(
    entitlementDocumentUrl(uid, result.originalTransactionId),
    {
      method: "PATCH",
      headers: {
        Authorization: `Bearer ${token}`,
        "Content-Type": "application/json",
      },
      body: JSON.stringify({
        fields: firestoreFields(uid, result),
      }),
    },
  );

  if (!response.ok) {
    throw new Error(
      `firestore_entitlement_write_failed_${response.status}`,
    );
  }
}

async function readEntitlement(
  uid: string,
  subscriptionId: string,
): Promise<JsonRecord | null> {
  const token = await runtimeAccessToken();
  const response = await fetch(
    entitlementDocumentUrl(uid, subscriptionId),
    {
      headers: {
        Authorization: `Bearer ${token}`,
      },
    },
  );

  if (response.status === 404) {
    return null;
  }

  if (!response.ok) {
    throw new Error(
      `firestore_entitlement_read_failed_${response.status}`,
    );
  }

  const document = readRecord(await response.json());
  return readRecord(document?.fields);
}

function findGoogleLineItem(
  value: unknown,
  productId: string,
): GoogleSubscriptionLineItem | null {
  if (!Array.isArray(value)) {
    return null;
  }

  for (const item of value) {
    const record = readRecord(item);

    if (
      record !== null &&
      readNonEmptyString(record.productId) === productId
    ) {
      return {
        expiryTime: record.expiryTime,
      };
    }
  }

  return null;
}

function appleProviderHttpStatus(error: unknown): number | null {
  const record = readRecord(error);

  if (record === null) {
    return null;
  }

  return (
    readFiniteNumber(record.status) ??
    readFiniteNumber(record.statusCode) ??
    readFiniteNumber(record.httpStatusCode)
  );
}

function alternateAppleEnvironment(
  environment: Environment,
): Environment {
  return environment === Environment.PRODUCTION ?
    Environment.SANDBOX :
    Environment.PRODUCTION;
}

async function verifyAppleTransactionInEnvironment(
  productId: string,
  transactionId: string,
  appleEnvironment: Environment,
): Promise<ProviderValidationResult | null> {
  const bundleId = requiredEnvironment(
    "FLOW_AI_APPLE_BUNDLE_ID",
  );
  const issuerId = requiredEnvironment(
    "FLOW_AI_APPLE_ISSUER_ID",
  );
  const keyId = requiredEnvironment(
    "FLOW_AI_APPLE_KEY_ID",
  );
  const privateKey = normalizePem(
    requiredEnvironment("FLOW_AI_APPLE_PRIVATE_KEY_P8"),
  );
  const rootCertificates = parseAppleRootCertificates(
    requiredEnvironment("FLOW_AI_APPLE_ROOT_CERTIFICATES_PEM"),
  );

  const client = new AppStoreServerAPIClient(
    privateKey,
    keyId,
    issuerId,
    bundleId,
    appleEnvironment,
  );

  const response = await client.getTransactionInfo(transactionId);
  const responseRecord = readRecord(response);
  const signedTransactionInfo = readNonEmptyString(
    responseRecord?.signedTransactionInfo,
  );

  if (signedTransactionInfo === null) {
    return null;
  }

  const verifier = new SignedDataVerifier(
    rootCertificates,
    false,
    appleEnvironment,
    bundleId,
  );

  const decoded = await verifier.verifyAndDecodeTransaction(
    signedTransactionInfo,
  );

  const decodedRecord = readRecord(decoded);

  if (decodedRecord === null) {
    return null;
  }

  const decodedProductId = readNonEmptyString(
    decodedRecord.productId,
  );
  const decodedTransactionId = readNonEmptyString(
    decodedRecord.transactionId,
  );
  const originalTransactionId = readNonEmptyString(
    decodedRecord.originalTransactionId,
  );
  const expiresDate = readFiniteNumber(
    decodedRecord.expiresDate,
  );
  const revocationDate = readFiniteNumber(
    decodedRecord.revocationDate,
  );

  if (
    decodedProductId !== productId ||
    decodedTransactionId !== transactionId ||
    originalTransactionId === null ||
    expiresDate === null ||
    revocationDate !== null ||
    expiresDate <= Date.now()
  ) {
    return null;
  }

  const statusResponse = await client.getAllSubscriptionStatuses(
    originalTransactionId,
  );

  const matchingItem = statusResponse.data
    ?.flatMap((group) => group.lastTransactions ?? [])
    .find(
      (item) =>
        item.originalTransactionId === originalTransactionId,
    );

  if (
    matchingItem === undefined ||
    matchingItem.status === undefined
  ) {
    return null;
  }

  if (
    matchingItem.status === Status.REVOKED ||
    matchingItem.status === Status.EXPIRED ||
    matchingItem.status === Status.BILLING_RETRY
  ) {
    return null;
  }

  let lifecycleStatus: LifecycleStatus;

  if (matchingItem.status === Status.ACTIVE) {
    lifecycleStatus = "active";
  } else if (
    matchingItem.status === Status.BILLING_GRACE_PERIOD
  ) {
    const signedRenewalInfo = readNonEmptyString(
      matchingItem.signedRenewalInfo,
    );

    if (signedRenewalInfo === null) {
      return null;
    }

    const renewal =
        await verifier.verifyAndDecodeRenewalInfo(
      signedRenewalInfo,
    );

    const renewalRecord = readRecord(renewal);

    const gracePeriodExpiresDate = readFiniteNumber(
      renewalRecord?.gracePeriodExpiresDate,
    );

    if (
      gracePeriodExpiresDate === null ||
      gracePeriodExpiresDate <= Date.now()
    ) {
      return null;
    }

    lifecycleStatus = "grace_period";
  } else {
    return null;
  }

  return {
    expirationDate: new Date(expiresDate),
    lifecycleStatus,
    originalTransactionId,
    platform: "ios",
    productId,
    provider: "apple",
    transactionId: decodedTransactionId,
  };
}

async function verifyAppleTransaction(
  productId: string,
  transactionId: string,
  environment: string,
): Promise<ProviderValidationResult | null> {
  const preferredEnvironment = toAppleEnvironment(environment);

  try {
    return await verifyAppleTransactionInEnvironment(
      productId,
      transactionId,
      preferredEnvironment,
    );
  } catch (error) {
    if (appleProviderHttpStatus(error) !== 404) {
      throw error;
    }
  }

  const fallbackEnvironment = alternateAppleEnvironment(
    preferredEnvironment,
  );

  try {
    return await verifyAppleTransactionInEnvironment(
      productId,
      transactionId,
      fallbackEnvironment,
    );
  } catch (error) {
    if (appleProviderHttpStatus(error) === 404) {
      return null;
    }

    throw error;
  }
}

async function verifyGoogleSubscription(
  purchaseToken: string,
  productId: string,
  packageName: string,
): Promise<ProviderValidationResult | null> {
  const accessToken = await googlePlayAccessToken();

  const url = [
    androidPublisherBaseUrl,
    "applications",
    encodeURIComponent(packageName),
    "purchases",
    "subscriptionsv2",
    "tokens",
    encodeURIComponent(purchaseToken),
  ].join("/");

  const response = await fetch(url, {
    headers: {
      Authorization: `Bearer ${accessToken}`,
    },
  });

  if (!response.ok) {
    throw new Error(
      `google_play_validation_failed_${response.status}`,
    );
  }

  const data = readRecord(await response.json());

  if (data === null) {
    return null;
  }

  const subscriptionState = readNonEmptyString(
    data.subscriptionState,
  );
  const lineItem = findGoogleLineItem(
    data.lineItems,
    productId,
  );
  const expiryTime = readNonEmptyString(
    lineItem?.expiryTime,
  );

  if (
    subscriptionState === null ||
    lineItem === null ||
    expiryTime === null
  ) {
    return null;
  }

  const expiryMillis = Date.parse(expiryTime);

  if (
    !Number.isFinite(expiryMillis) ||
    expiryMillis <= Date.now()
  ) {
    return null;
  }

  let lifecycleStatus: LifecycleStatus;

  if (
    subscriptionState === "SUBSCRIPTION_STATE_ACTIVE"
  ) {
    lifecycleStatus = "active";
  } else if (
    subscriptionState ===
    "SUBSCRIPTION_STATE_IN_GRACE_PERIOD"
  ) {
    lifecycleStatus = "grace_period";
  } else if (
    subscriptionState ===
    "SUBSCRIPTION_STATE_CANCELED"
  ) {
    lifecycleStatus = "paid_through_cancellation";
  } else {
    return null;
  }

  const subscriptionId = hashIdentifier(
    `google:${packageName}:${purchaseToken}`,
  );

  return {
    expirationDate: new Date(expiryMillis),
    lifecycleStatus,
    originalTransactionId: subscriptionId,
    platform: "android",
    productId,
    provider: "google",
    transactionId: subscriptionId,
  };
}

async function handleReceiptValidation(
  request: IncomingMessage,
  response: ServerResponse,
  uid: string,
  platform: Platform,
): Promise<void> {
  if (request.method !== "POST") {
    throw new HttpError(405, "method_not_allowed");
  }

  const body = await readJsonBody(request);
  const productIdValue = requiredString(
    body,
    "productId",
    128,
  );

  if (!allowedProducts.has(productIdValue)) {
    throw new HttpError(400, "invalid_request");
  }

  let result: ProviderValidationResult | null;

  if (platform === "ios") {
    const environment = requiredString(
      body,
      "environment",
      16,
    );
    const transactionId = requiredString(
      body,
      "transactionId",
      256,
    );

    if (!allowedAppleEnvironments.has(environment)) {
      throw new HttpError(400, "invalid_request");
    }

    result = await verifyAppleTransaction(
      productIdValue,
      transactionId,
      environment,
    );
  } else {
    const packageName = requiredString(
      body,
      "packageName",
      256,
    );
    const purchaseToken = requiredString(
      body,
      "purchaseToken",
      60 * 1024,
    );
    const configuredPackageName = requiredEnvironment(
      "FLOW_AI_GOOGLE_PACKAGE_NAME",
    );

    if (packageName !== configuredPackageName) {
      throw new HttpError(400, "invalid_request");
    }

    result = await verifyGoogleSubscription(
      purchaseToken,
      productIdValue,
      packageName,
    );
  }

  if (result === null) {
    sendJson(response, 200, {
      error: "receipt_not_active",
      valid: false,
    });
    return;
  }

  await persistAfterReceiptOwnership(
    uid,
    result,
    assertReceiptOwnership,
    persistValidatedEntitlement,
  );

  sendJson(response, 200, {
    expirationDate: result.expirationDate.toISOString(),
    lifecycleStatus: result.lifecycleStatus,
    originalTransactionId: result.originalTransactionId,
    productId: result.productId,
    transactionId: result.transactionId,
    valid: true,
  });
}

function readFirestoreBoolean(
  fields: JsonRecord,
  key: string,
): boolean {
  const field = readRecord(fields[key]);
  return field?.booleanValue === true;
}

function readFirestoreString(
  fields: JsonRecord,
  key: string,
): string | null {
  const field = readRecord(fields[key]);
  return readNonEmptyString(field?.stringValue);
}

function readFirestoreInteger(
  fields: JsonRecord,
  key: string,
): number | null {
  const field = readRecord(fields[key]);
  return readIntegerValue(field?.integerValue);
}

async function handleSubscriptionStatus(
  request: IncomingMessage,
  response: ServerResponse,
  uid: string,
  subscriptionId: string,
): Promise<void> {
  if (request.method !== "GET") {
    throw new HttpError(405, "method_not_allowed");
  }

  if (
    subscriptionId.length === 0 ||
    subscriptionId.length > 256
  ) {
    throw new HttpError(400, "invalid_request");
  }

  const fields = await readEntitlement(
    uid,
    subscriptionId,
  );

  if (fields === null) {
    sendJson(response, 200, {
      active: false,
      error: "entitlement_not_found",
    });
    return;
  }

  const active = readFirestoreBoolean(
    fields,
    "active",
  );
  const expiresAtMillis = readFirestoreInteger(
    fields,
    "expiresAtMillis",
  );
  const productIdValue = readFirestoreString(
    fields,
    "productId",
  );
  const platformValue = readFirestoreString(
    fields,
    "platform",
  );
  const transactionId = readFirestoreString(
    fields,
    "transactionId",
  );
  const originalTransactionId = readFirestoreString(
    fields,
    "originalTransactionId",
  );

  if (
    !active ||
    expiresAtMillis === null ||
    expiresAtMillis <= Date.now() ||
    productIdValue === null ||
    transactionId === null ||
    originalTransactionId === null ||
    (
      platformValue !== "ios" &&
      platformValue !== "android"
    )
  ) {
    sendJson(response, 200, {
      active: false,
      error: "entitlement_inactive",
    });
    return;
  }

  sendJson(response, 200, {
    active: true,
    expirationDate: new Date(
      expiresAtMillis,
    ).toISOString(),
    originalTransactionId,
    platform: platformValue,
    productId: productIdValue,
    transactionId,
  });
}

function parseSubscriptionId(
  pathname: string,
): string | null {
  const segments = pathname
    .split("/")
    .filter((segment) => segment.length > 0);

  if (
    segments.length !== 3 ||
    segments[0] !== "v1" ||
    segments[1] !== "subscriptions"
  ) {
    return null;
  }

  try {
    return decodeURIComponent(segments[2] ?? "");
  } catch {
    throw new HttpError(400, "invalid_request");
  }
}

async function handleRequest(
  request: IncomingMessage,
  response: ServerResponse,
): Promise<void> {
  try {
    const url = new URL(
      request.url ?? "/",
      "http://localhost",
    );

    if (
      request.method === "GET" &&
      url.pathname === "/health"
    ) {
      sendJson(response, 200, {
        architecture: runtimeArchitecture,
        status: "ok",
      });
      return;
    }

    const isAppleRoute =
      url.pathname === "/v1/receipts/apple";
    const isGoogleRoute =
      url.pathname === "/v1/receipts/google";
    const subscriptionId = parseSubscriptionId(
      url.pathname,
    );

    if (
      !isAppleRoute &&
      !isGoogleRoute &&
      subscriptionId === null
    ) {
      throw new HttpError(404, "not_found");
    }

    const uid = await requireFirebaseUid(request);

    if (isAppleRoute) {
      await handleReceiptValidation(
        request,
        response,
        uid,
        "ios",
      );
      return;
    }

    if (isGoogleRoute) {
      await handleReceiptValidation(
        request,
        response,
        uid,
        "android",
      );
      return;
    }

    await handleSubscriptionStatus(
      request,
      response,
      uid,
      subscriptionId ?? "",
    );
  } catch (error) {
    if (error instanceof HttpError) {
      sendJson(response, error.statusCode, {
        error: error.safeCode,
      });
      return;
    }

    if (error instanceof ProviderConfigurationError) {
      sendJson(response, 503, {
        error: "provider_configuration_error",
      });
      return;
    }

    const errorRecord = readRecord(error);

    console.error("receipt_service_request_failed", {
      category:
        error instanceof Error ?
          error.name :
          "unknown",
      code:
        readNonEmptyString(errorRecord?.code) ??
        readNonEmptyString(errorRecord?.errorCode) ??
        readNonEmptyString(errorRecord?.apiError),
      message:
        error instanceof Error ?
          error.message.slice(0, 300) :
          null,
      status:
        readIntegerValue(errorRecord?.status) ??
        readIntegerValue(errorRecord?.statusCode) ??
        readIntegerValue(errorRecord?.httpStatusCode),
    });

    sendJson(response, 502, {
      error: "provider_validation_failed",
    });
  }
}

export function createReceiptServer(): Server {
  return createServer((request, response) => {
    void handleRequest(request, response);
  });
}

function startServer(): void {
  const rawPort = process.env.PORT ?? "8080";
  const port = Number.parseInt(rawPort, 10);

  if (
    !Number.isSafeInteger(port) ||
    port < 1 ||
    port > 65_535
  ) {
    throw new Error("invalid_port");
  }

  const server = createReceiptServer();

  server.listen(port, "0.0.0.0", () => {
    console.log("receipt_service_listening", {
      architecture: runtimeArchitecture,
      port,
    });
  });
}

const entryPoint = process.argv[1];

if (
  entryPoint !== undefined &&
  import.meta.url === pathToFileURL(entryPoint).href
) {
  startServer();
}
