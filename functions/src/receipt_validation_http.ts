import {
  onRequest,
} from "firebase-functions/v2/https";
import {
  logger,
} from "firebase-functions";
import {
  defineSecret,
} from "firebase-functions/params";

type ReceiptValidationResponse = {
  valid: boolean;
  expirationDate?: string;
  transactionId?: string;
  originalTransactionId?: string;
  error?: string;
};

type SubscriptionStatusResponse = {
  active: boolean;
  error?: string;
};

type SecretValue = {
  value: () => string;
};

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

const allowedPlatforms = new Set([
  "ios",
  "android",
]);

const allowedAppleEnvironments = new Set([
  "production",
  "sandbox",
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
 * Handles the shared receipt validation request contract used by the app.
 *
 * The endpoint is intentionally fail-closed. It validates transport, payload
 * shape, and provider secret readiness, but refuses entitlement until provider
 * verification and server-side entitlement persistence are implemented.
 *
 * @param {unknown} request Express request object from Firebase.
 * @param {unknown} response Express response object from Firebase.
 * @param {"ios"|"android"} expectedPlatform Expected platform.
 */
function handleReceiptValidation(
  request: {
    method?: string;
    body?: Record<string, unknown>;
  },
  response: Parameters<typeof sendJson>[0],
  expectedPlatform: "ios" | "android",
): void {
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

  if (expectedPlatform === "android") {
    const configuredPackageName = readSecret(googlePackageName);
    if (
      configuredPackageName === null ||
      packageName !== configuredPackageName
    ) {
      sendJson(response, 400, {
        valid: false,
        error: "invalid_receipt_validation_request",
      });
      return;
    }
  }

  logger.warn("Receipt validation provider integration is not implemented", {
    platform,
    productId,
    userIdHashPrefix: userId.slice(0, 8),
  });

  sendJson(response, 501, {
    valid: false,
    error: "provider_validation_not_configured",
  });
}

/**
 * Validates an Apple receipt through the Flow AI backend contract.
 */
export const validateAppleReceipt = onRequest(
  {
    secrets: appleProviderSecrets,
  },
  (request, response) => {
    handleReceiptValidation(request, response, "ios");
  },
);

/**
 * Validates a Google Play purchase token through the Flow AI backend contract.
 */
export const validateGooglePlayReceipt = onRequest(
  {
    secrets: googleProviderSecrets,
  },
  (request, response) => {
    handleReceiptValidation(request, response, "android");
  },
);

/**
 * Verifies persisted subscription status through the Flow AI backend contract.
 *
 * The app calls this endpoint as:
 *   GET /<userId>/<subscriptionId>
 *
 * It intentionally returns inactive until entitlement storage/provider status
 * verification is implemented.
 */
export const subscriptionStatus = onRequest((request, response) => {
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

  logger.warn("Subscription status provider integration is not configured", {
    userId,
    subscriptionId,
  });

  sendJson(response, 200, {
    active: false,
    error: "provider_validation_not_configured",
  });
});
