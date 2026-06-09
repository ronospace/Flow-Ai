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
  defineSecret,
} from "firebase-functions/params";
import {
  HttpsError,
  onCall,
} from "firebase-functions/v2/https";

import sgMail from "@sendgrid/mail";

import {
  assertInviteIsActive,
  escapeHtml,
  getInviteOwnerUid,
  getInviteRecipientEmail,
  JsonMap,
  MAX_EMAIL_LENGTH,
  MAX_LINK_LENGTH,
  MAX_MESSAGE_LENGTH,
  normalizeEmailAddress,
  normalizeHttpsInvitationLink,
  normalizeInvitationCode,
  optionalBoundedString,
  requiredBoundedString,
  requireAuthenticatedUid,
  requireRequestData,
  timestampToMillis,
} from "./partner_security_primitives";

if (getApps().length === 0) {
  initializeApp();
}

const db = getFirestore();

const SENDGRID_API_KEY =
  defineSecret("SENDGRID_API_KEY");
const SENDGRID_FROM_EMAIL =
  defineSecret("SENDGRID_FROM_EMAIL");

const INVITES_COLLECTION =
  "partnerInvites";
const EMAIL_LEASE_MILLIS =
  2 * 60 * 1000;

type EmailLeaseDecision = {
  shouldSend: boolean;
  personalMessage: string;
};

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
 * Resolves exactly one invitation document.
 * @param {string} invitationCode Normalized invitation code.
 * @return {Promise<*>} Invitation document reference.
 */
async function resolveInviteReference(
  invitationCode: string,
): Promise<DocumentReference> {
  const references =
    await findInviteReferences(
      invitationCode,
    );

  if (references.length === 0) {
    throw new HttpsError(
      "not-found",
      "Invitation was not found.",
    );
  }

  if (references.length !== 1) {
    throw new HttpsError(
      "failed-precondition",
      "Invitation code is ambiguous.",
    );
  }

  return references[0];
}

/**
 * Returns the verified SendGrid sender address.
 * @return {string} Configured sender address.
 */
function requireConfiguredSenderEmail(): string {
  try {
    return normalizeEmailAddress(
      SENDGRID_FROM_EMAIL.value(),
    );
  } catch {
    console.error(
      "PARTNER_EMAIL_CONFIGURATION_INVALID",
    );

    throw new HttpsError(
      "internal",
      "Invitation email is temporarily unavailable.",
    );
  }
}

/**
 * Returns a non-sensitive provider status code.
 * @param {unknown} error SendGrid failure.
 * @return {*} Provider status code or null.
 */
function extractStatusCode(
  error: unknown,
): number | null {
  if (
    error == null ||
    typeof error !== "object"
  ) {
    return null;
  }

  const candidate = error as {
    code?: unknown;
    response?: {
      statusCode?: unknown;
    };
  };

  if (typeof candidate.code === "number") {
    return candidate.code;
  }

  if (
    typeof candidate.response?.statusCode ===
      "number"
  ) {
    return candidate.response.statusCode;
  }

  return null;
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

export const secureSendPartnerInvite = onCall(
  {
    timeoutSeconds: 30,
    secrets: [
      SENDGRID_API_KEY,
      SENDGRID_FROM_EMAIL,
    ],
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

    const recipientEmail =
      normalizeEmailAddress(
        requiredBoundedString(
          data,
          "email",
          MAX_EMAIL_LENGTH,
        ),
      );

    const requestedMessage =
      optionalBoundedString(
        data,
        "personalMessage",
        MAX_MESSAGE_LENGTH,
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

    try {
      const reference =
        await resolveInviteReference(
          invitationCode,
        );

      const decision =
        await db.runTransaction(
          async (transaction):
          Promise<EmailLeaseDecision> => {
            const snapshot =
              await transaction.get(
                reference,
              );

            if (!snapshot.exists) {
              throw new HttpsError(
                "not-found",
                "Invitation was not found.",
              );
            }

            const invitation =
              snapshot.data() as JsonMap;

            const ownerUid =
              getInviteOwnerUid(
                invitation,
              );

            if (
              !ownerUid ||
              ownerUid !== uid
            ) {
              throw new HttpsError(
                "permission-denied",
                "Invitation ownership could not be verified.",
              );
            }

            assertInviteIsActive(
              invitation,
            );

            const existingRecipient =
              getInviteRecipientEmail(
                invitation,
              );

            if (
              existingRecipient &&
              existingRecipient !==
                recipientEmail
            ) {
              throw new HttpsError(
                "failed-precondition",
                "Invitation recipient cannot be changed.",
              );
            }

            const existingLink =
              typeof invitation[
                "invitationLink"
              ] === "string" ?
                invitation[
                  "invitationLink"
                ].trim() :
                "";

            if (
              existingLink &&
              existingLink !== invitationLink
            ) {
              throw new HttpsError(
                "failed-precondition",
                "Invitation link cannot be changed.",
              );
            }

            const existingMessage =
              typeof invitation[
                "personalMessage"
              ] === "string" ?
                invitation[
                  "personalMessage"
                ].trim() :
                "";

            if (
              existingMessage &&
              requestedMessage &&
              existingMessage !==
                requestedMessage
            ) {
              throw new HttpsError(
                "failed-precondition",
                "Invitation message cannot be changed.",
              );
            }

            if (
              invitation["emailStatus"] ===
                "sent" &&
              existingRecipient ===
                recipientEmail
            ) {
              return {
                shouldSend: false,
                personalMessage:
                  existingMessage,
              };
            }

            const leaseUntil =
              timestampToMillis(
                invitation[
                  "emailLeaseUntil"
                ],
              );

            if (
              invitation["emailStatus"] ===
                "sending" &&
              leaseUntil != null &&
              leaseUntil > Date.now()
            ) {
              throw new HttpsError(
                "aborted",
                "Invitation email is already being sent.",
              );
            }

            const personalMessage =
              existingMessage ||
              requestedMessage;

            transaction.set(
              reference,
              {
                recipientEmail,
                toEmail: recipientEmail,
                inviteeEmail:
                  recipientEmail,
                personalMessage:
                  personalMessage || null,
                invitationLink,
                emailStatus: "sending",
                emailLeaseUntil:
                  Timestamp.fromMillis(
                    Date.now() +
                    EMAIL_LEASE_MILLIS,
                  ),
                updatedAt:
                  FieldValue.serverTimestamp(),
              },
              {
                merge: true,
              },
            );

            return {
              shouldSend: true,
              personalMessage,
            };
          },
        );

      if (!decision.shouldSend) {
        return {
          ok: true,
          alreadySent: true,
        };
      }

      try {
        const senderEmail =
          requireConfiguredSenderEmail();

        sgMail.setApiKey(
          SENDGRID_API_KEY.value(),
        );

        const escapedMessage =
          escapeHtml(
            decision.personalMessage,
          );
        const escapedCode =
          escapeHtml(invitationCode);
        const escapedLink =
          escapeHtml(invitationLink);

        const html = `
          <div style="font-family:-apple-system,BlinkMacSystemFont,Segoe UI,Roboto,Arial,sans-serif;line-height:1.5">
            <h2>You're invited to connect on Flow AI</h2>
            ${escapedMessage ? `<p><strong>Message:</strong> ${escapedMessage}</p>` : ""}
            <p><strong>Invite code:</strong> ${escapedCode}</p>
            <p><a href="${escapedLink}">Open Flow AI invitation</a></p>
            <p>If the link does not open, enter the invite code in Flow AI.</p>
          </div>
        `;

        const [response] =
          await sgMail.send({
            to: recipientEmail,
            from: senderEmail,
            subject:
              "Flow AI Partner Invitation",
            text: [
              "You're invited to connect on Flow AI.",
              decision.personalMessage ?
                `Message: ${decision.personalMessage}` :
                "",
              `Invite code: ${invitationCode}`,
              `Invitation link: ${invitationLink}`,
            ]
              .filter(Boolean)
              .join("\n"),
            html,
          });

        await reference.set(
          {
            emailStatus: "sent",
            sendgridStatus:
              response?.statusCode ?? null,
            emailSentAt:
              FieldValue.serverTimestamp(),
            emailLeaseUntil:
              FieldValue.delete(),
            updatedAt:
              FieldValue.serverTimestamp(),
          },
          {
            merge: true,
          },
        );

        console.log(
          "PARTNER_EMAIL_SENT",
          {
            statusCode:
              response?.statusCode ?? null,
          },
        );

        return {
          ok: true,
          alreadySent: false,
        };
      } catch (error: unknown) {
        const statusCode =
          extractStatusCode(error);

        try {
          await reference.set(
            {
              emailStatus: "failed",
              sendgridStatus: statusCode,
              emailFailureAt:
                FieldValue.serverTimestamp(),
              emailLeaseUntil:
                FieldValue.delete(),
              updatedAt:
                FieldValue.serverTimestamp(),
            },
            {
              merge: true,
            },
          );
        } catch (stateError: unknown) {
          console.error(
            "PARTNER_EMAIL_STATE_UPDATE_FAILED",
            {
              category:
                stateError instanceof Error ?
                  stateError.name :
                  "unknown",
            },
          );
        }

        console.error(
          "PARTNER_EMAIL_FAILED",
          {
            statusCode,
            category:
              error instanceof Error ?
                error.name :
                "unknown",
          },
        );

        if (error instanceof HttpsError) {
          throw error;
        }

        throw new HttpsError(
          "unavailable",
          "Invitation email could not be sent. Please retry.",
        );
      }
    } catch (error) {
      throwSafeFailure(
        "secureSendPartnerInvite",
        error,
      );
    }
  },
);
