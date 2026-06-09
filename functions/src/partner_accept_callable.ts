/* eslint-disable max-len */
import {
  getApps,
  initializeApp,
} from "firebase-admin/app";
import {
  FieldValue,
  getFirestore,
  Timestamp,
} from "firebase-admin/firestore";
import type {
  DocumentReference,
} from "firebase-admin/firestore";
import {
  HttpsError,
  onCall,
} from "firebase-functions/v2/https";

import {
  assertInviteIsActive,
  getInviteOwnerUid,
  JsonMap,
  normalizeInvitationCode,
  requiredBoundedString,
  requireAuthenticatedUid,
  requireRequestData,
} from "./partner_security_primitives";

if (getApps().length === 0) {
  initializeApp();
}

const db = getFirestore();
const INVITES_COLLECTION = "partnerInvites";
const CONNECTIONS_COLLECTION = "partnerConnections";

const DEFAULT_PRIVACY_SETTINGS = {
  shareBasicCycleInfo: true,
  shareDetailedSymptoms: false,
  shareMoodData: true,
  shareEnergyLevels: true,
  sharePainData: false,
  shareAIInsights: true,
  sharePredictions: true,
  allowNotifications: true,
  allowCareActions: true,
  shareHistoricalData: false,
  restrictedDataTypes: [] as string[],
};

/**
 * Finds exactly one current or legacy invitation document.
 * @param {string} invitationCode Normalized invitation code.
 * @return {Promise<*>} Invitation document reference.
 */
async function resolveInviteReference(
  invitationCode: string,
): Promise<DocumentReference> {
  const references = new Map<string, DocumentReference>();

  const directReference = db
    .collection(INVITES_COLLECTION)
    .doc(invitationCode);
  const directSnapshot = await directReference.get();

  if (directSnapshot.exists) {
    references.set(directReference.path, directReference);
  }

  for (const field of ["invitationCode", "code"]) {
    const snapshot = await db
      .collection(INVITES_COLLECTION)
      .where(field, "==", invitationCode)
      .limit(2)
      .get();

    for (const document of snapshot.docs) {
      references.set(document.ref.path, document.ref);
    }
  }

  if (references.size === 0) {
    throw new HttpsError(
      "not-found",
      "Invitation was not found.",
    );
  }

  if (references.size !== 1) {
    throw new HttpsError(
      "failed-precondition",
      "Invitation code is ambiguous.",
    );
  }

  return [...references.values()][0];
}

/**
 * Converts unexpected backend failures to safe callable errors.
 * @param {string} operation Internal operation identifier.
 * @param {unknown} error Caught backend failure.
 * @throws {HttpsError} Always throws a safe callable error.
 */
function throwSafeFailure(
  operation: string,
  error: unknown,
): never {
  if (error instanceof HttpsError) {
    throw error;
  }

  console.error(
    "PARTNER_OPERATION_FAILED",
    {
      operation,
      category: error instanceof Error ? error.name : "unknown",
    },
  );

  throw new HttpsError(
    "internal",
    "The operation could not be completed.",
  );
}

export const acceptPartnerInvite = onCall(
  {
    timeoutSeconds: 30,
  },
  async (request) => {
    const uid = requireAuthenticatedUid(request.auth);
    const data = requireRequestData(request.data);
    const invitationCode = normalizeInvitationCode(
      requiredBoundedString(
        data,
        "invitationCode",
        6,
      ),
    );

    try {
      const invitationReference = await resolveInviteReference(
        invitationCode,
      );
      const nowMillis = Date.now();
      const nowIso = new Date(nowMillis).toISOString();

      return await db.runTransaction(
        async (transaction) => {
          const invitationSnapshot = await transaction.get(
            invitationReference,
          );

          if (!invitationSnapshot.exists) {
            throw new HttpsError(
              "not-found",
              "Invitation was not found.",
            );
          }

          const invitation = invitationSnapshot.data() as JsonMap;
          const ownerUid = getInviteOwnerUid(invitation);

          if (!ownerUid) {
            throw new HttpsError(
              "failed-precondition",
              "Invitation ownership is unavailable.",
            );
          }

          if (ownerUid === uid) {
            throw new HttpsError(
              "failed-precondition",
              "You cannot accept your own invitation.",
            );
          }

          assertInviteIsActive(invitation, nowMillis);

          const participants = [ownerUid, uid].sort();
          const connectionId = participants.join("_");
          const connectionReference = db
            .collection(CONNECTIONS_COLLECTION)
            .doc(connectionId);
          const connectionSnapshot = await transaction.get(
            connectionReference,
          );

          const partnership = {
            id: connectionId,
            userId1: participants[0],
            userId2: participants[1],
            customName1: null,
            customName2: null,
            establishedAt: nowIso,
            status: "active",
            privacySettings: DEFAULT_PRIVACY_SETTINGS,
            lastActiveAt: nowIso,
          };

          if (connectionSnapshot.exists) {
            const existing = connectionSnapshot.data() as JsonMap;
            const existingUserId1 = existing["userId1"];
            const existingUserId2 = existing["userId2"];

            if (
              existingUserId1 !== participants[0] ||
              existingUserId2 !== participants[1]
            ) {
              throw new HttpsError(
                "already-exists",
                "Connection identifier is already in use.",
              );
            }
          } else {
            transaction.create(
              connectionReference,
              {
                ...partnership,
                schemaVersion: 2,
                participantUids: participants,
                invitationCode,
                establishedAtTimestamp: Timestamp.fromMillis(nowMillis),
                createdAt: FieldValue.serverTimestamp(),
                updatedAt: FieldValue.serverTimestamp(),
              },
            );
          }

          transaction.set(
            invitationReference,
            {
              schemaVersion: 2,
              ownerUid,
              status: "accepted",
              acceptedByUid: uid,
              acceptedAt: FieldValue.serverTimestamp(),
              connectionId,
              updatedAt: FieldValue.serverTimestamp(),
            },
            {
              merge: true,
            },
          );

          return partnership;
        },
      );
    } catch (error) {
      throwSafeFailure(
        "acceptPartnerInvite",
        error,
      );
    }
  },
);
