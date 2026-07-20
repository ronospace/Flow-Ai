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
  logger,
} from "firebase-functions/logger";

import {
  assertInviteIsActive,
  getInviteOwnerUid,
  JsonMap,
  MAX_EMAIL_LENGTH,
  MAX_LINK_LENGTH,
  MAX_MESSAGE_LENGTH,
  MAX_NAME_LENGTH,
  normalizeEmailAddress,
  normalizeHttpsInvitationLink,
  normalizeInvitationCode,
  optionalBoundedString,
  requiredBoundedString,
  requireAuthenticatedUid,
  requireInviteExpiryMillis,
  requireRequestData,
} from "./partner_security_primitives";

if (getApps().length === 0) {
  initializeApp();
}

const db = getFirestore();
const INVITES_COLLECTION = "partnerInvites";

/**
 * Finds current and preserved legacy invitation documents.
 * @param {string} invitationCode Normalized invitation code.
 * @return {Promise<*>} Unique invitation references.
 */
async function findInviteReferences(
  invitationCode: string,
): Promise<DocumentReference[]> {
  const references =
    new Map<string, DocumentReference>();

  const directReference = db
    .collection(INVITES_COLLECTION)
    .doc(invitationCode);

  const directSnapshot =
    await directReference.get();

  if (directSnapshot.exists) {
    references.set(
      directReference.path,
      directReference,
    );
  }

  for (
    const field of [
      "invitationCode",
      "code",
    ]
  ) {
    const snapshot = await db
      .collection(INVITES_COLLECTION)
      .where(field, "==", invitationCode)
      .limit(2)
      .get();

    for (const document of snapshot.docs) {
      references.set(
        document.ref.path,
        document.ref,
      );
    }
  }

  return [...references.values()];
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

  logger.error(
    "PARTNER_OPERATION_FAILED",
    {
      operation,
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

export const publishPartnerInvite = onCall(
  {
    timeoutSeconds: 30,
  },
  async (request) => {
    const uid =
      requireAuthenticatedUid(
        request.auth,
      );

    const data =
      requireRequestData(
        request.data,
      );

    const invitationCode =
      normalizeInvitationCode(
        requiredBoundedString(
          data,
          "invitationCode",
          6,
        ),
      );

    const invitationLink =
      normalizeHttpsInvitationLink(
        requiredBoundedString(
          data,
          "invitationLink",
          MAX_LINK_LENGTH,
        ),
        invitationCode,
      );

    const personalMessage =
      optionalBoundedString(
        data,
        "personalMessage",
        MAX_MESSAGE_LENGTH,
      );

    const inviterName =
      optionalBoundedString(
        data,
        "inviterName",
        MAX_NAME_LENGTH,
      );

    const inviterEmail =
      normalizeEmailAddress(
        optionalBoundedString(
          data,
          "inviterEmail",
          MAX_EMAIL_LENGTH,
        ),
        false,
      );

    const recipientEmail =
      normalizeEmailAddress(
        optionalBoundedString(
          data,
          "recipientEmail",
          MAX_EMAIL_LENGTH,
        ),
        false,
      );

    const expiresAtMillis =
      requireInviteExpiryMillis(data);

    try {
      const references =
        await findInviteReferences(
          invitationCode,
        );

      if (references.length > 1) {
        throw new HttpsError(
          "failed-precondition",
          "Invitation code is ambiguous.",
        );
      }

      const reference =
        references.length === 1 ?
          references[0] :
          db
            .collection(
              INVITES_COLLECTION,
            )
            .doc(invitationCode);

      const created =
        await db.runTransaction(
          async (transaction) => {
            const snapshot =
              await transaction.get(
                reference,
              );

            const existing: JsonMap | null =
              snapshot.exists ?
                snapshot.data() as JsonMap :
                null;

            if (existing !== null) {
              const existingOwner =
                getInviteOwnerUid(
                  existing,
                );

              if (
                !existingOwner ||
                existingOwner !== uid
              ) {
                throw new HttpsError(
                  "already-exists",
                  "Invitation code is already owned.",
                );
              }

              assertInviteIsActive(
                existing,
              );
            }

            const createdAt =
              existing === null ?
                FieldValue.serverTimestamp() :
                existing["createdAt"] ??
                  FieldValue.serverTimestamp();

            transaction.set(
              reference,
              {
                schemaVersion: 2,
                invitationCode,
                code: invitationCode,
                ownerUid: uid,
                fromUid: uid,
                inviterId: uid,
                inviterName:
                  inviterName || null,
                inviterEmail:
                  inviterEmail || null,
                recipientEmail:
                  recipientEmail || null,
                toEmail:
                  recipientEmail || null,
                inviteeEmail:
                  recipientEmail || null,
                personalMessage:
                  personalMessage || null,
                invitationLink,
                status: "active",
                expiresAt:
                  Timestamp.fromMillis(
                    expiresAtMillis,
                  ),
                createdAt,
                updatedAt:
                  FieldValue.serverTimestamp(),
              },
              {
                merge: true,
              },
            );

            return existing === null;
          },
        );

      return {
        ok: true,
        invitationCode,
        created,
      };
    } catch (error) {
      throwSafeFailure(
        "publishPartnerInvite",
        error,
      );
    }
  },
);
