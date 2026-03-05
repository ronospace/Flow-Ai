# Flow AI Mission Log

## Non-negotiable Rules (always)
- One mission at a time.
- Only bash blocks in terminal steps (no mixing notes + commands).
- Every mission has a Definition of Done.
- Any new discovery goes into Queue (we don’t context-switch).
- One branch per mission.
- Always write down errors/screenshots as “Evidence” with date/time.

## Evidence (screenshots / logs)
- Google Sign-in error: "Apps with uid ... cannot masquerade as package com.flowai.app" (Screenshot: 2026-03-05 00:59:52)
- Prior Google sign-in error: ApiException: 10 (DEVELOPER_ERROR)
- Deep link error: GoException: no routes for location flowai://invite/TEST123

## North Star
Invite deep-links reliably convert: web → app → join partner, with correct auth gating (works cold start + logged out + logged in).

## Current Mission
[M1] Deep link normalization + GoRouter route mapping + post-auth invite queue handoff.

## Definition of Done (M1)
- flowai://invite/TEST123 opens app
- Join Partner opens with code prefilled (ABC123)
- Works when logged out (stores pendingInviteCode → after login opens join)
- Works from cold start (killed app)

## Queue (next)
[M2] Google Sign-In Android: fix config mismatch (masquerade/ApiException 10) + refresh google-services.json
[M3] Email Sign Up uses createUser (fix “No account found” on signup)
[M4] Biometrics gating + clearer messaging
[M5] Remove Demo UI + remove demo codepaths (prod)
[M6] Glass UI polish where applicable (targeted)

## Done
- Kotlin Gradle plugin updated and kotlinOptions migrated to compilerOptions DSL
- Hosted invite redirect page deployed to Firebase Hosting
- JoinPartnerDialog supports initialCode and prefills input

## Notes / Decisions
- Canonical invite path: /invite/:code
- Pending invite code key: pendingInviteCode
