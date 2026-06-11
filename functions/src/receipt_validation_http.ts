import {
  onRequest,
} from "firebase-functions/v2/https";
import {
  logger,
} from "firebase-functions";

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

const jsonHeaders = {
  "Content-Type": "application/json",
  "Cache-Control": "no-store",
};

const allowedPlatforms = new Set([
  "ios",
  "android",
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
 * Handles the shared receipt validation request contract used by the app.
 *
 * The endpoint is intentionally fail-closed. It validates transport and payload
 * shape, logs only non-sensitive metadata, and refuses entitlement until the
 * provider verification implementation is added with secure secrets.
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

  if (
    receipt === null ||
    productId === null ||
    platform === null ||
    !allowedPlatforms.has(platform) ||
    platform !== expectedPlatform
  ) {
    sendJson(response, 400, {
      valid: false,
      error: "invalid_receipt_validation_request",
    });
    return;
  }

  if (expectedPlatform === "android") {
    const packageName = readNonEmptyString(body.packageName);
    if (packageName === null) {
      sendJson(response, 400, {
        valid: false,
        error: "invalid_receipt_validation_request",
      });
      return;
    }
  }

  logger.warn("Receipt validation provider integration is not configured", {
    productId,
    platform,
  });

  sendJson(response, 501, {
    valid: false,
    error: "provider_validation_not_configured",
  });
}

/**
 * Validates an Apple receipt through the Flow AI backend contract.
 */
export const validateAppleReceipt = onRequest((request, response) => {
  handleReceiptValidation(request, response, "ios");
});

/**
 * Validates a Google Play purchase token through the Flow AI backend contract.
 */
export const validateGooglePlayReceipt = onRequest((request, response) => {
  handleReceiptValidation(request, response, "android");
});

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
