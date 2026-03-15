/* eslint-disable max-len */
import {onCall, HttpsError} from "firebase-functions/v2/https";
import {defineSecret} from "firebase-functions/params";
import {initializeApp} from "firebase-admin/app";

import sgMail from "@sendgrid/mail";

initializeApp();


const SENDGRID_API_KEY = defineSecret("SENDGRID_API_KEY");
const SENDGRID_FROM_EMAIL = defineSecret("SENDGRID_FROM_EMAIL");

export const sendPartnerInvite = onCall(
  {secrets: [SENDGRID_API_KEY, SENDGRID_FROM_EMAIL]},
  async (req) => {
    const uid = req.auth?.uid;
    if (!uid) {
      throw new HttpsError("unauthenticated", "Login required");
    }

    const email = String(req.data?.email ?? "").trim().toLowerCase();
    const personalMessage = String(req.data?.personalMessage ?? "").trim();
    const invitationCode = String(req.data?.invitationCode ?? "").trim();
    const invitationLink = String(req.data?.invitationLink ?? "").trim();

    if (!email || !email.includes("@")) {
      throw new HttpsError("invalid-argument", "Invalid email");
    }
    if (!invitationCode) {
      throw new HttpsError("invalid-argument", "Missing invitationCode");
    }
    if (!invitationLink) {
      throw new HttpsError("invalid-argument", "Missing invitationLink");
    }

    const html = `
      <div style="font-family:-apple-system,Segoe UI,Roboto,Arial,sans-serif;line-height:1.4">
        <h2>You're invited to connect on Flow Ai</h2>
        ${personalMessage ? `<p><b>Message:</b> ${personalMessage}</p>` : ""}
        <p><b>Invite code:</b> ${invitationCode}</p>
        <p><a href="${invitationLink}">Tap to join</a></p>
        <p>If the link doesn’t open, paste this code in the app: <b>${invitationCode}</b></p>
      </div>
    `;
    const apiKey = SENDGRID_API_KEY.value();
    sgMail.setApiKey(apiKey);
    try {
      const fromEmail = SENDGRID_FROM_EMAIL.value();
      const [resp] = await sgMail.send({
        to: email,
        from: fromEmail,
        subject: "Flow Ai Partner Invitation",
        html,
      });
      return {
        ok: true,
        statusCode: resp?.statusCode ?? null,
      };
    } catch (err: unknown) {
      const e = err as { code?: unknown; response?: { statusCode?: unknown; body?: unknown } } | null;
      const statusCode =
        (typeof e?.code === "number" ? e?.code : null) ??
        (typeof e?.response?.statusCode === "number" ? e?.response?.statusCode : null);
      const body = e?.response?.body ?? null;
      console.error("SENDGRID_ERROR", JSON.stringify({
        statusCode,
        body,
        code: e?.code ?? null,
      }));

      throw new HttpsError(
        "internal",
        `SendGrid failed (status=${statusCode}) body=${JSON.stringify(body)}`
      );
    }
  }
);
// redeploy marker Sun Mar  1 23:41:58 CET 2026
// redeploy marker Tue Mar  3 15:12:28 CET 2026
// redeploy marker Tue Mar  3 15:14:17 CET 2026
// redeploy marker Tue Mar  3 15:15:22 CET 2026
