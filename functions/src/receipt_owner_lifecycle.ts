/* eslint-disable max-len */

import {
  getApps,
  initializeApp,
} from "firebase-admin/app";
import {
  FieldValue,
  getFirestore,
} from "firebase-admin/firestore";
import {
  logger,
} from "firebase-functions/logger";
import * as functionsV1 from "firebase-functions/v1";

if (getApps().length === 0) {
  initializeApp();
}

const db = getFirestore();

const RECEIPT_OWNERS_COLLECTION =
  "premiumReceiptOwners";

export type ReceiptOwnerDeletionFields = {
  ownerStatus: "auth_deleted";
  deletedOwnerUid: string;
  deletedAt: unknown;
  schemaVersion: number;
};

/**
 * Builds the authoritative receipt-owner deletion lifecycle fields.
 *
 * @param {string} uid Firebase Auth UID confirmed deleted by the Auth lifecycle event.
 * @param {unknown} deletedAt Authoritative server deletion timestamp sentinel/value.
 * @return {ReceiptOwnerDeletionFields} Receipt-owner deletion lifecycle fields.
 */
export function buildReceiptOwnerDeletionFields(
  uid: string,
  deletedAt: unknown,
): ReceiptOwnerDeletionFields {
  if (uid.trim().length === 0) {
    throw new Error(
      "receipt_owner_deleted_uid_required",
    );
  }

  return {
    ownerStatus: "auth_deleted",
    deletedOwnerUid: uid,
    deletedAt,
    schemaVersion: 2,
  };
}

/**
 * Determines whether the current receipt-owner document may be
 * transitioned by the authoritative Auth deletion event.
 *
 * @param {Record<string, unknown>} data Current transaction snapshot data.
 * @param {string} uid Firebase Auth UID confirmed deleted.
 * @return {boolean} Whether this exact current owner may transition.
 */
export function shouldMarkReceiptOwnerAuthDeleted(
  data: Record<string, unknown>,
  uid: string,
): boolean {
  if (data.ownerUid !== uid) {
    return false;
  }

  return !(
    data.ownerStatus === "auth_deleted" &&
    data.deletedOwnerUid === uid
  );
}

/**
 * Marks all receipt-owner documents for a deleted Firebase Auth UID.
 *
 * @param {string} uid Firebase Auth UID from the authoritative Auth delete event.
 * @return {Promise<number>} Number of owner documents transitioned to auth_deleted.
 */
export async function markReceiptOwnersAuthDeleted(
  uid: string,
): Promise<number> {
  if (uid.trim().length === 0) {
    throw new Error(
      "receipt_owner_deleted_uid_required",
    );
  }

  const snapshot = await db
    .collection(RECEIPT_OWNERS_COLLECTION)
    .where("ownerUid", "==", uid)
    .get();

  let transitionedCount = 0;

  for (const document of snapshot.docs) {
    const transitioned = await db.runTransaction(
      async (transaction) => {
        const current =
          await transaction.get(document.ref);

        if (!current.exists) {
          return false;
        }

        const data = current.data();

        if (data === undefined) {
          return false;
        }

        if (
          !shouldMarkReceiptOwnerAuthDeleted(
            data,
            uid,
          )
        ) {
          return false;
        }

        transaction.update(
          document.ref,
          buildReceiptOwnerDeletionFields(
            uid,
            FieldValue.serverTimestamp(),
          ),
        );

        return true;
      },
    );

    if (transitioned) {
      transitionedCount += 1;
    }
  }

  return transitionedCount;
}

export const releaseReceiptOwnersOnAuthDelete =
  functionsV1
    .runWith({
      failurePolicy: true,
    })
    .auth
    .user()
    .onDelete(async (user) => {
      const releasedCount =
        await markReceiptOwnersAuthDeleted(
          user.uid,
        );

      logger.info(
        "PREMIUM_RECEIPT_OWNERS_AUTH_DELETED",
        {
          releasedCount,
        },
      );
    });
