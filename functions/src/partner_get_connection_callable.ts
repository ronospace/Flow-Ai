/* eslint-disable max-len */
import {
  getApps,
  initializeApp,
} from "firebase-admin/app";
import {
  getFirestore,
} from "firebase-admin/firestore";
import type {
  DocumentReference,
  QueryDocumentSnapshot,
} from "firebase-admin/firestore";
import {
  HttpsError,
  onCall,
} from "firebase-functions/v2/https";
import {
  logger,
} from "firebase-functions/logger";

import {
  JsonMap,
  requireAuthenticatedUid,
} from "./partner_security_primitives";

if (getApps().length === 0) {
  initializeApp();
}

const db = getFirestore();
const CONNECTIONS_COLLECTION = "partnerConnections";

/**
 * Adds query documents to a path-deduplicated result map.
 * @param {Map<string, QueryDocumentSnapshot>} target Result map.
 * @param {QueryDocumentSnapshot[]} documents Query documents.
 * @return {void}
 */
function addDocuments(
  target: Map<string, QueryDocumentSnapshot>,
  documents: QueryDocumentSnapshot[],
): void {
  for (const document of documents) {
    target.set(document.ref.path, document);
  }
}

/**
 * Returns a validated partnership owned by the authenticated account.
 * @param {DocumentReference} reference Partnership document reference.
 * @param {JsonMap} data Partnership document data.
 * @param {string} uid Authenticated Firebase user id.
 * @return {JsonMap} Safe partnership payload.
 */
function safePartnership(
  reference: DocumentReference,
  data: JsonMap,
  uid: string,
): JsonMap {
  const participantUids = Array.isArray(data["participantUids"]) ?
    data["participantUids"] :
    [];

  const userId1 = data["userId1"];
  const userId2 = data["userId2"];

  const ownsConnection =
    participantUids.includes(uid) ||
    userId1 === uid ||
    userId2 === uid;

  if (!ownsConnection) {
    throw new HttpsError(
      "permission-denied",
      "The partnership is not owned by the authenticated account.",
    );
  }

  if (
    typeof userId1 !== "string" ||
    typeof userId2 !== "string" ||
    userId1.length === 0 ||
    userId2.length === 0
  ) {
    throw new HttpsError(
      "failed-precondition",
      "The partnership record is incomplete.",
    );
  }

  return {
    id: typeof data["id"] === "string" ? data["id"] : reference.id,
    userId1,
    userId2,
    customName1: data["customName1"] ?? null,
    customName2: data["customName2"] ?? null,
    establishedAt: data["establishedAt"],
    status: data["status"],
    privacySettings: data["privacySettings"] ?? {},
    lastActiveAt: data["lastActiveAt"] ?? data["establishedAt"],
  };
}

export const getPartnerConnection = onCall(
  {
    timeoutSeconds: 30,
  },
  async (request) => {
    const uid = requireAuthenticatedUid(request.auth);

    try {
      const results =
        new Map<string, QueryDocumentSnapshot>();

      const participantSnapshot = await db
        .collection(CONNECTIONS_COLLECTION)
        .where("participantUids", "array-contains", uid)
        .limit(2)
        .get();

      addDocuments(results, participantSnapshot.docs);

      // Legacy compatibility only. New records use participantUids.
      if (results.size === 0) {
        const [primarySnapshot, partnerSnapshot] =
          await Promise.all([
            db
              .collection(CONNECTIONS_COLLECTION)
              .where("userId1", "==", uid)
              .limit(2)
              .get(),
            db
              .collection(CONNECTIONS_COLLECTION)
              .where("userId2", "==", uid)
              .limit(2)
              .get(),
          ]);

        addDocuments(results, primarySnapshot.docs);
        addDocuments(results, partnerSnapshot.docs);
      }

      if (results.size === 0) {
        return {
          partnership: null,
        };
      }

      if (results.size !== 1) {
        throw new HttpsError(
          "failed-precondition",
          "Multiple active partnership records were found.",
        );
      }

      const document = [...results.values()][0];
      const data = document.data() as JsonMap;

      if (data["status"] !== "active") {
        return {
          partnership: null,
        };
      }

      return {
        partnership: safePartnership(
          document.ref,
          data,
          uid,
        ),
      };
    } catch (error) {
      if (error instanceof HttpsError) {
        throw error;
      }

      logger.error(
        "PARTNER_OPERATION_FAILED",
        {
          operation: "getPartnerConnection",
          category:
            error instanceof Error ?
              error.name :
              "unknown",
        },
      );

      throw new HttpsError(
        "internal",
        "The operation could not be completed.",
      );
    }
  },
);
