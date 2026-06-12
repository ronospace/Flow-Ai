import {
  AppStoreServerAPIClient,
  Environment,
  SignedDataVerifier,
} from "@apple/app-store-server-library";
import {
  getApps,
  initializeApp,
} from "firebase-admin/app";
import {
  FieldValue,
  getFirestore,
  Timestamp,
} from "firebase-admin/firestore";
import {
  onRequest,
} from "firebase-functions/v2/https";
import {
  logger,
} from "firebase-functions";
import {
  defineSecret,
} from "firebase-functions/params";
import {
  createHash,
} from "crypto";
import {
  GoogleAuth,
} from "google-auth-library";

type ReceiptValidationResponse = {
  valid: boolean;
  expirationDate?: string;
  transactionId?: string;
  originalTransactionId?: string;
  error?: string;
};

type SubscriptionStatusResponse = {
  active: boolean;
  expirationDate?: string;
  transactionId?: string;
  originalTransactionId?: string;
  productId?: string;
  platform?: "ios" | "android";
  error?: string;
};

type SecretValue = {
  value: () => string;
};

type ProviderValidationResult = {
  platform: "ios" | "android";
  provider: "apple" | "google";
  productId: string;
  transactionId: string;
  originalTransactionId: string;
  expirationDate: Date;
};

type GoogleServiceAccountCredentials = {
  client_email: string;
  private_key: string;
};

type GoogleSubscriptionLineItem = {
  expiryTime?: unknown;
};

type GoogleSubscriptionV2Response = {
  subscriptionState?: unknown;
  latestOrderId?: unknown;
  lineItems?: unknown;
};

/**
 * Signals unsafe or incomplete provider configuration.
 */
class ProviderConfigurationError extends Error {
  /**
   * Creates a safe provider configuration error.
   */
  constructor() {
    super("provider_configuration_error");
  }
}

if (getApps().length === 0) {
  initializeApp();
}

const db = getFirestore();

const appleBundleId = defineSecret("FLOW_AI_APPLE_BUNDLE_ID");
const appleIssuerId = defineSecret("FLOW_AI_APPLE_ISSUER_ID");
const appleKeyId = defineSecret("FLOW_AI_APPLE_KEY_ID");
const applePrivateKeyP8 = defineSecret("FLOW_AI_APPLE_PRIVATE_KEY_P8");
const appleRootCertificatesPem = defineSecret(
  "FLOW_AI_APPLE_ROOT_CERTIFICATES_PEM",
);
const googlePackageName = defineSecret("FLOW_AI_GOOGLE_PACKAGE_NAME");
const googleServiceAccountJson = defineSecret(
  "FLOW_AI_GOOGLE_SERVICE_ACCOUNT_JSON",
);

const appleProviderSecrets = [
  appleBundleId,
  appleIssuerId,
  appleKeyId,
  applePrivateKeyP8,
  appleRootCertificatesPem,
];

const googleProviderSecrets = [
  googlePackageName,
  googleServiceAccountJson,
];

const jsonHeaders = {
  "Content-Type": "application/json",
  "Cache-Control": "no-store",
};

const entitlementsCollection = "premiumEntitlements";
const subscriptionsCollection = "subscriptions";
const androidPublisherScope =
  "https://www.googleapis.com/auth/androidpublisher";
const androidPublisherBaseUrl =
  "https://androidpublisher.googleapis.com/androidpublisher/v3";

const allowedPlatforms = new Set([
  "ios",
  "android",
]);

const allowedAppleEnvironments = new Set([
  "production",
  "sandbox",
]);

const activeGoogleSubscriptionStates = new Set([
  "SUBSCRIPTION_STATE_ACTIVE",
  "SUBSCRIPTION_STATE_IN_GRACE_PERIOD",
]);

/**
 * Sends a JSON response with no-store caching.
 *
 * @param {unknown} response Express response object from Firebase.
 * @param {number} statusCode HTTP status code.
 * @param {ReceiptValidationResponse|SubscriptionStatusResponse} body Body.
 */
function sendJson(
  response: {
    status: (code: number) => {
      set: (headers: Record<string, string>) => {
        send: (body: unknown) => void;
      };
    };
  },
  statusCode: number,
  body: ReceiptValidationResponse | SubscriptionStatusResponse,
): void {
  response.status(statusCode).set(jsonHeaders).send(body);
}

/**
 * Returns a trimmed string value from unknown JSON data.
 *
 * @param {unknown} value Candidate value.
 * @return {string|null} Trimmed string or null.
 */
function readNonEmptyString(value: unknown): string | null {
  if (typeof value !== "string") {
    return null;
  }

  const trimmed = value.trim();
  return trimmed.length > 0 ? trimmed : null;
}

/**
 * Reads a number value from unknown JSON data.
 *
 * @param {unknown} value Candidate value.
 * @return {number|null} Finite number or null.
 */
function readFiniteNumber(value: unknown): number | null {
  if (typeof value !== "number" || !Number.isFinite(value)) {
    return null;
  }

  return value;
}

/**
 * Reads a Firebase secret value without leaking it to logs.
 *
 * @param {SecretValue} secret Firebase secret parameter.
 * @return {string|null} Non-empty secret value, or null.
 */
function readSecret(secret: SecretValue): string | null {
  try {
    const value = secret.value().trim();
    return value.length > 0 ? value : null;
  } catch {
    return null;
  }
}

/**
 * Returns missing Apple provider secret names.
 *
 * @return {string[]} Missing secret names.
 */
function missingAppleProviderSecrets(): string[] {
  const missing: string[] = [];

  if (readSecret(appleBundleId) === null) {
    missing.push("FLOW_AI_APPLE_BUNDLE_ID");
  }
  if (readSecret(appleIssuerId) === null) {
    missing.push("FLOW_AI_APPLE_ISSUER_ID");
  }
  if (readSecret(appleKeyId) === null) {
    missing.push("FLOW_AI_APPLE_KEY_ID");
  }
  if (readSecret(applePrivateKeyP8) === null) {
    missing.push("FLOW_AI_APPLE_PRIVATE_KEY_P8");
  }
  if (readSecret(appleRootCertificatesPem) === null) {
    missing.push("FLOW_AI_APPLE_ROOT_CERTIFICATES_PEM");
  }

  return missing;
}

/**
 * Returns missing Google provider secret names.
 *
 * @return {string[]} Missing secret names.
 */
function missingGoogleProviderSecrets(): string[] {
  const missing: string[] = [];

  if (readSecret(googlePackageName) === null) {
    missing.push("FLOW_AI_GOOGLE_PACKAGE_NAME");
  }
  if (readSecret(googleServiceAccountJson) === null) {
    missing.push("FLOW_AI_GOOGLE_SERVICE_ACCOUNT_JSON");
  }

  return missing;
}

/**
 * Safely hashes an identifier for internal document IDs.
 *
 * @param {string} input Raw identifier.
 * @return {string} SHA-256 hex digest.
 */
function hashIdentifier(input: string): string {
  return createHash("sha256").update(input).digest("hex");
}

/**
 * Converts escaped newline secrets back to PEM format.
 *
 * @param {string} value Secret value.
 * @return {string} PEM string.
 */
function normalizePemSecret(value: string): string {
  return value.replace(/\\n/g, "\n");
}

/**
 * Parses one or more PEM root certificates to buffers.
 *
 * @param {string} pemBundle PEM bundle.
 * @return {Buffer[]} Certificate buffers.
 */
function parseAppleRootCertificates(pemBundle: string): Buffer[] {
  const normalized = normalizePemSecret(pemBundle);
  const matches = normalized.match(
    /-----BEGIN CERTIFICATE-----[\s\S]+?-----END CERTIFICATE-----/g,
  ) ?? [];

  return matches.map((certificate) => Buffer.from(certificate));
}

/**
 * Returns the Apple SDK environment for a request environment.
 *
 * @param {string} environment Request environment.
 * @return {Environment} Apple SDK environment.
 */
function toAppleEnvironment(environment: string): Environment {
  return environment === "production" ?
    Environment.PRODUCTION :
    Environment.SANDBOX;
}

/**
 * Reads a plain object record from unknown data.
 *
 * @param {unknown} value Candidate value.
 * @return {Record<string, unknown>|null} Plain object or null.
 */
function readRecord(value: unknown): Record<string, unknown> | null {
  if (
    value === null ||
    typeof value !== "object" ||
    Array.isArray(value)
  ) {
    return null;
  }

  return value as Record<string, unknown>;
}

/**
 * Parses Google service-account credentials from a secret.
 *
 * @param {string} json Secret JSON.
 * @return {GoogleServiceAccountCredentials} Google credentials.
 */
function parseGoogleCredentials(
  json: string,
): GoogleServiceAccountCredentials {
  const parsed = readRecord(JSON.parse(json));

  if (parsed === null) {
    throw new ProviderConfigurationError();
  }

  const clientEmail = readNonEmptyString(parsed.client_email);
  const privateKey = readNonEmptyString(parsed.private_key);

  if (clientEmail === null || privateKey === null) {
    throw new ProviderConfigurationError();
  }

  return {
    client_email: clientEmail,
    private_key: normalizePemSecret(privateKey),
  };
}

/**
 * Finds a Google subscription line item for the requested product.
 *
 * @param {unknown} value Line items value.
 * @param {string} productId Requested product ID.
 * @return {GoogleSubscriptionLineItem|null} Matching line item.
 */
function findGoogleLineItem(
  value: unknown,
  productId: string,
): GoogleSubscriptionLineItem | null {
  if (!Array.isArray(value)) {
    return null;
  }

  for (const item of value) {
    const record = readRecord(item);
    if (record === null) {
      continue;
    }

    if (readNonEmptyString(record.productId) === productId) {
      return {
        expiryTime: record.expiryTime,
      };
    }
  }

  return null;
}

/**
 * Persists a provider-validated entitlement before returning entitlement.
 *
 * @param {string} userId User identifier.
 * @param {ProviderValidationResult} result Provider validation result.
 */
async function persistValidatedEntitlement(
  userId: string,
  result: ProviderValidationResult,
): Promise<void> {
  const document = db
    .collection(entitlementsCollection)
    .doc(userId)
    .collection(subscriptionsCollection)
    .doc(result.originalTransactionId);

  await document.set(
    {
      active: result.expirationDate.getTime() > Date.now(),
      expiresAt: Timestamp.fromMillis(result.expirationDate.getTime()),
      expiresAtMillis: result.expirationDate.getTime(),
      originalTransactionId: result.originalTransactionId,
      platform: result.platform,
      productId: result.productId,
      provider: result.provider,
      transactionId: result.transactionId,
      updatedAt: FieldValue.serverTimestamp(),
      userId,
      validatedAt: FieldValue.serverTimestamp(),
    },
    {
      merge: true,
    },
  );
}

/**
 * Verifies an Apple App Store transaction through Apple's server API.
 *
 * @param {string} productId Requested product ID.
 * @param {string} transactionId App Store transaction ID.
 * @param {string} environment App Store environment.
 * @return {Promise<ProviderValidationResult|null>} Validation result.
 */
async function verifyAppleTransaction(
  productId: string,
  transactionId: string,
  environment: string,
): Promise<ProviderValidationResult | null> {
  const bundleId = readSecret(appleBundleId);
  const issuerId = readSecret(appleIssuerId);
  const keyId = readSecret(appleKeyId);
  const privateKey = readSecret(applePrivateKeyP8);
  const rootCertificates = readSecret(appleRootCertificatesPem);

  if (
    bundleId === null ||
    issuerId === null ||
    keyId === null ||
    privateKey === null ||
    rootCertificates === null
  ) {
    throw new ProviderConfigurationError();
  }

  const appleEnvironment = toAppleEnvironment(environment);
  const client = new AppStoreServerAPIClient(
    normalizePemSecret(privateKey),
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
    parseAppleRootCertificates(rootCertificates),
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

  const decodedProductId = readNonEmptyString(decodedRecord.productId);
  const decodedTransactionId = readNonEmptyString(decodedRecord.transactionId);
  const originalTransactionId = readNonEmptyString(
    decodedRecord.originalTransactionId,
  );
  const expiresDate = readFiniteNumber(decodedRecord.expiresDate);
  const revocationDate = readFiniteNumber(decodedRecord.revocationDate);

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

/**
 * Verifies a Google Play subscription purchase token.
 *
 * @param {string} purchaseToken Google Play purchase token.
 * @param {string} productId Requested product ID.
 * @param {string} packageName Android package name.
 * @return {Promise<ProviderValidationResult|null>} Validation result.
 */
async function verifyGoogleSubscription(
  purchaseToken: string,
  productId: string,
  packageName: string,
): Promise<ProviderValidationResult | null> {
  const serviceAccountJson = readSecret(googleServiceAccountJson);
  if (serviceAccountJson === null) {
    throw new ProviderConfigurationError();
  }

  const credentials = parseGoogleCredentials(serviceAccountJson);
  const auth = new GoogleAuth({
    credentials,
    scopes: [
      androidPublisherScope,
    ],
  });
  const client = await auth.getClient();
  const url = [
    androidPublisherBaseUrl,
    "applications",
    encodeURIComponent(packageName),
    "purchases",
    "subscriptionsv2",
    "tokens",
    encodeURIComponent(purchaseToken),
  ].join("/");

  const response = await client.request<GoogleSubscriptionV2Response>({
    method: "GET",
    url,
  });
  const data = readRecord(response.data);
  if (data === null) {
    return null;
  }

  const subscriptionState = readNonEmptyString(data.subscriptionState);
  const lineItem = findGoogleLineItem(data.lineItems, productId);
  const expiryTime = readNonEmptyString(lineItem?.expiryTime);
  if (
    subscriptionState === null ||
    !activeGoogleSubscriptionStates.has(subscriptionState) ||
    lineItem === null ||
    expiryTime === null
  ) {
    return null;
  }

  const expiryMillis = Date.parse(expiryTime);
  if (!Number.isFinite(expiryMillis) || expiryMillis <= Date.now()) {
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

/**
 * Handles the shared receipt validation request contract used by the app.
 *
 * @param {unknown} request Express request object from Firebase.
 * @param {unknown} response Express response object from Firebase.
 * @param {"ios"|"android"} expectedPlatform Expected platform.
 */
async function handleReceiptValidation(
  request: {
    method?: string;
    body?: Record<string, unknown>;
  },
  response: Parameters<typeof sendJson>[0],
  expectedPlatform: "ios" | "android",
): Promise<void> {
  if (request.method !== "POST") {
    sendJson(response, 405, {
      valid: false,
      error: "method_not_allowed",
    });
    return;
  }

  const body = request.body ?? {};
  const receipt = readNonEmptyString(body.receipt);
  const productId = readNonEmptyString(body.productId);
  const platform = readNonEmptyString(body.platform);
  const userId = readNonEmptyString(body.userId);
  let packageName: string | null = null;
  let appleEnvironment: string | null = null;
  let appleTransactionId: string | null = null;

  if (
    receipt === null ||
    productId === null ||
    platform === null ||
    userId === null ||
    !allowedPlatforms.has(platform) ||
    platform !== expectedPlatform
  ) {
    sendJson(response, 400, {
      valid: false,
      error: "invalid_receipt_validation_request",
    });
    return;
  }

  if (expectedPlatform === "ios") {
    appleEnvironment = readNonEmptyString(body.environment);
    appleTransactionId = readNonEmptyString(body.transactionId);
    if (
      appleEnvironment === null ||
      appleTransactionId === null ||
      !allowedAppleEnvironments.has(appleEnvironment)
    ) {
      sendJson(response, 400, {
        valid: false,
        error: "invalid_receipt_validation_request",
      });
      return;
    }
  }

  if (expectedPlatform === "android") {
    packageName = readNonEmptyString(body.packageName);
    if (packageName === null) {
      sendJson(response, 400, {
        valid: false,
        error: "invalid_receipt_validation_request",
      });
      return;
    }
  }

  const missingSecrets = expectedPlatform === "ios" ?
    missingAppleProviderSecrets() :
    missingGoogleProviderSecrets();

  if (missingSecrets.length > 0) {
    logger.error("Receipt validation provider secrets are not configured", {
      missingSecretCount: missingSecrets.length,
      platform,
    });

    sendJson(response, 503, {
      valid: false,
      error: "provider_secrets_not_configured",
    });
    return;
  }

  const configuredPackageName = readSecret(googlePackageName);
  if (
    expectedPlatform === "android" &&
    (configuredPackageName === null || packageName !== configuredPackageName)
  ) {
    sendJson(response, 400, {
      valid: false,
      error: "invalid_receipt_validation_request",
    });
    return;
  }

  try {
    const validationResult = expectedPlatform === "ios" ?
      await verifyAppleTransaction(
        productId,
        appleTransactionId ?? "",
        appleEnvironment ?? "",
      ) :
      await verifyGoogleSubscription(
        receipt,
        productId,
        packageName ?? "",
      );

    if (validationResult === null) {
      sendJson(response, 200, {
        valid: false,
        error: "receipt_not_active",
      });
      return;
    }

    await persistValidatedEntitlement(userId, validationResult);

    sendJson(response, 200, {
      expirationDate: validationResult.expirationDate.toISOString(),
      originalTransactionId: validationResult.originalTransactionId,
      transactionId: validationResult.transactionId,
      valid: true,
    });
  } catch (error) {
    const safeError = error instanceof ProviderConfigurationError ?
      "provider_secrets_not_configured" :
      "provider_validation_failed";
    const statusCode = safeError === "provider_secrets_not_configured" ?
      503 :
      502;

    logger.error("Receipt validation provider request failed", {
      category: error instanceof Error ? error.name : "unknown",
      platform,
    });

    sendJson(response, statusCode, {
      valid: false,
      error: safeError,
    });
  }
}

/**
 * Validates an Apple receipt through the Flow AI backend contract.
 */
export const validateAppleReceipt = onRequest(
  {
    secrets: appleProviderSecrets,
  },
  async (request, response) => {
    await handleReceiptValidation(request, response, "ios");
  },
);

/**
 * Validates a Google Play purchase token through the Flow AI backend contract.
 */
export const validateGooglePlayReceipt = onRequest(
  {
    secrets: googleProviderSecrets,
  },
  async (request, response) => {
    await handleReceiptValidation(request, response, "android");
  },
);

/**
 * Verifies persisted subscription status through server-side entitlement state.
 */
export const subscriptionStatus = onRequest(async (request, response) => {
  if (request.method !== "GET") {
    sendJson(response, 405, {
      active: false,
      error: "method_not_allowed",
    });
    return;
  }

  const pathSegments = request.path
    .split("/")
    .map((segment) => segment.trim())
    .filter((segment) => segment.length > 0);

  const userId = pathSegments[0] ?? null;
  const subscriptionId = pathSegments[1] ?? null;

  if (
    userId === null ||
    subscriptionId === null ||
    pathSegments.length !== 2
  ) {
    sendJson(response, 400, {
      active: false,
      error: "invalid_subscription_status_request",
    });
    return;
  }

  const snapshot = await db
    .collection(entitlementsCollection)
    .doc(userId)
    .collection(subscriptionsCollection)
    .doc(subscriptionId)
    .get();

  if (!snapshot.exists) {
    sendJson(response, 200, {
      active: false,
      error: "entitlement_not_found",
    });
    return;
  }

  const data = snapshot.data() ?? {};
  const active = data.active === true;
  const expiresAtMillis = readFiniteNumber(data.expiresAtMillis);
  const productId = readNonEmptyString(data.productId);
  const platform = readNonEmptyString(data.platform);
  const transactionId = readNonEmptyString(data.transactionId);
  const originalTransactionId = readNonEmptyString(
    data.originalTransactionId,
  );

  if (
    !active ||
    expiresAtMillis === null ||
    expiresAtMillis <= Date.now() ||
    productId === null ||
    transactionId === null ||
    originalTransactionId === null ||
    (platform !== "ios" && platform !== "android")
  ) {
    sendJson(response, 200, {
      active: false,
      error: "entitlement_inactive",
    });
    return;
  }

  sendJson(response, 200, {
    active: true,
    expirationDate: new Date(expiresAtMillis).toISOString(),
    originalTransactionId,
    platform,
    productId,
    transactionId,
  });
});
