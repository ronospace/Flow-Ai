/* eslint-disable max-len */
import {onCall, HttpsError} from "firebase-functions/v2/https";
import {defineSecret} from "firebase-functions/params";
import {initializeApp} from "firebase-admin/app";
import {getFirestore, FieldValue} from "firebase-admin/firestore";

initializeApp();
const db = getFirestore();

const RESEND_API_KEY = defineSecret("RESEND_API_KEY");

export const sendPartnerInvite = onCall({secrets: [RESEND_API_KEY]}, async (req) => {
  const uid = req.auth?.uid;
  if (!uid) throw new HttpsError("unauthenticated", "Login required");

  const email = String(req.data?.email ?? "").trim().toLowerCase();
  const personalMessage = String(req.data?.personalMessage ?? "").trim();
  const invitationCode = String(req.data?.invitationCode ?? "").trim();
  const invitationLink = String(req.data?.invitationLink ?? "").trim();

  if (!email || !email.includes("@")) throw new HttpsError("invalid-argument", "Invalid email");
  if (!invitationCode) throw new HttpsError("invalid-argument", "Missing invitationCode");
  if (!invitationLink) throw new HttpsError("invalid-argument", "Missing invitationLink");

  await db.collection("partnerInvites").add({
    fromUid: uid,
    toEmail: email,
    invitationCode,
    invitationLink,
    personalMessage,
    createdAt: FieldValue.serverTimestamp(),
  });

  const subject = "Flow Ai Partner Invitation";
  const html = `
    <div style="font-family:-apple-system,Segoe UI,Roboto,Arial,sans-serif;line-height:1.4">
      <h2>You're invited to connect on Flow Ai</h2>
      ${personalMessage ? `<p><b>Message:</b> ${personalMessage}</p>` : ""}
      <p><b>Invite code:</b> ${invitationCode}</p>
      <p><a href="${invitationLink}">Tap to join</a></p>
      <p>If the link doesn’t open, paste this code in the app: <b>${invitationCode}</b></p>
    </div>
  `;

  const from = "Flow Ai <no-reply@YOUR_DOMAIN>";
  const resp = await fetch("https://api.resend.com/emails", {
    method: "POST",
    headers: {
      "Authorization": `Bearer ${RESEND_API_KEY.value()}`,
      "Content-Type": "application/json",
    },
    body: JSON.stringify({from, to: [email], subject, html}),
  });

  if (!resp.ok) {
    const txt = await resp.text();
    throw new HttpsError("internal", `Resend failed: ${resp.status} ${txt}`);
  }

  const json = await resp.json();
  return {ok: true, id: json?.id ?? null};
});
