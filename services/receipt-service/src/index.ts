import {
  AppStoreServerAPIClient,
  Environment,
  SignedDataVerifier,
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

type ProviderValidationResult = {
  platform: Platform;
  provider: "apple" | "google";
  productId: string;
  transactionId: string;
  originalTransactionId: string;
  expirationDate: Date;
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

const activeGoogleSubscriptionStates = new Set([
  "SUBSCRIPTION_STATE_ACTIVE",
  "SUBSCRIPTION_STATE_IN_GRACE_PERIOD",
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
    /-----BEGIN CERTIFICATE-----[\s\S]+?-----END CERTIFICATE-----/g,
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

async function verifyAppleTransaction(
  productId: string,
  transactionId: string,
  environment: string,
): Promise<ProviderValidationResult | null> {
  const bundleId = requiredEnvironment(
    "FLOW_AI_APPLE_BUNDLE_ID",
  );
  const issuerId = requiredEnvironment(
    "FLOW_AI_APPLE_ISSUER_ID_NEXT",
  );
  const keyId = requiredEnvironment(
    "FLOW_AI_APPLE_KEY_ID_NEXT",
  );
  const privateKey = normalizePem(
    requiredEnvironment("FLOW_AI_APPLE_PRIVATE_KEY_P8_NEXT"),
  );
  const rootCertificates = parseAppleRootCertificates(
    requiredEnvironment("FLOW_AI_APPLE_ROOT_CERTIFICATES_PEM"),
  );

  const appleEnvironment = toAppleEnvironment(environment);

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

  return {
    expirationDate: new Date(expiresDate),
    originalTransactionId,
    platform: "ios",
    productId,
    provider: "apple",
    transactionId: decodedTransactionId,
  };
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
    !activeGoogleSubscriptionStates.has(subscriptionState) ||
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

  const subscriptionId = hashIdentifier(
    `google:${packageName}:${purchaseToken}`,
  );

  return {
    expirationDate: new Date(expiryMillis),
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

  await persistValidatedEntitlement(uid, result);

  sendJson(response, 200, {
    expirationDate: result.expirationDate.toISOString(),
    originalTransactionId: result.originalTransactionId,
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

    console.error("receipt_service_request_failed", {
      category:
        error instanceof Error ?
          error.name :
          "unknown",
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
