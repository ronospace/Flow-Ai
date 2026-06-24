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
} from "firebase-admin/firestore";
import {
  HttpsError,
  onCall,
} from "firebase-functions/v2/https";

import {
  requireAuthenticatedUid,
} from "./partner_security_primitives";

if (getApps().length === 0) {
  initializeApp();
}

const db = getFirestore();

const INVITES_COLLECTION = "partnerInvites";
const CONNECTIONS_COLLECTION = "partnerConnections";
const ENTITLEMENTS_COLLECTION = "premiumEntitlements";
const SUBSCRIPTIONS_COLLECTION = "subscriptions";

export const deleteMyCloudData = onCall(
  {
    timeoutSeconds: 60,
  },
  async (request) => {
    const uid = requireAuthenticatedUid(
      request.auth,
    );

    try {
      const entitlementReference = db
        .collection(ENTITLEMENTS_COLLECTION)
        .doc(uid);
      const entitlementSubscriptions =
        await entitlementReference
          .collection(SUBSCRIPTIONS_COLLECTION)
          .get();

      // Delete the entitlement document and every nested subscription.
      await db.recursiveDelete(entitlementReference);

      const snapshots = await Promise.all([
        db
          .collection(INVITES_COLLECTION)
          .where("ownerUid", "==", uid)
          .get(),
        db
          .collection(INVITES_COLLECTION)
          .where("fromUid", "==", uid)
          .get(),
        db
          .collection(INVITES_COLLECTION)
          .where("inviterId", "==", uid)
          .get(),
        db
          .collection(INVITES_COLLECTION)
          .where("acceptedByUid", "==", uid)
          .get(),
        db
          .collection(CONNECTIONS_COLLECTION)
          .where(
            "participantUids",
            "array-contains",
            uid,
          )
          .get(),
        db
          .collection(CONNECTIONS_COLLECTION)
          .where("userId1", "==", uid)
          .get(),
        db
          .collection(CONNECTIONS_COLLECTION)
          .where("userId2", "==", uid)
          .get(),
      ]);

      const references =
        new Map<string, DocumentReference>();

      for (const snapshot of snapshots) {
        for (const document of snapshot.docs) {
          references.set(
            document.ref.path,
            document.ref,
          );
        }
      }

      const documents = [...references.values()];

      for (
        let offset = 0;
        offset < documents.length;
        offset += 400
      ) {
        const batch = db.batch();

        for (
          const reference of documents.slice(
            offset,
            offset + 400,
          )
        ) {
          batch.delete(reference);
        }

        await batch.commit();
      }

      const deletedDocuments =
        documents.length + entitlementSubscriptions.size;

      console.log(
        "USER_CLOUD_DATA_DELETED",
        {
          documentCount: deletedDocuments,
        },
      );

      return {
        ok: true,
        deletedDocuments,
      };
    } catch (error) {
      if (error instanceof HttpsError) {
        throw error;
      }

      console.error(
        "PARTNER_CLOUD_DELETE_FAILED",
        {
          category:
            error instanceof Error ?
              error.name :
              "unknown",
        },
      );

      throw new HttpsError(
        "internal",
        "Cloud data could not be deleted.",
      );
    }
  },
);
