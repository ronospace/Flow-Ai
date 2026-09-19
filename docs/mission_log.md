<!-- FLOW_AI_CURRENT_RELEASE_STATE_BEGIN -->
# Flow Ai — Current Release State

> **Authoritative current-state block.**
> Historical mission entries below intentionally preserve earlier OPEN/ACTIVE states.
> Automation and release triage must use this block first and must not infer current
> status from older historical sections.

## Current release progress

- General: 71%
- Monetization: 73%
- Identity & Cloud: 60%
- Wellness/Health: 100%

## Current release missions

- MON-12/15 — Final Release Integrity: 95%
- MON-13/15 — Android Purchase/Restore: 100% — CLOSED
- MON-14/15 — iPhone Purchase/Restore: 100% — CLOSED — physical fresh purchase PASS + Restore Purchases PASS
- MON-15/15 — Final E2E Regression: 65%

## Current active / pending work

1. MON12-OBS1A — 100% — CLOSED — Android physical persistent-navigation telemetry verified.
2. MON12-BILL1 — 95% — compliant Billing 8 release artifact verified; Play Console deployment/confirmation pending.
3. MON12-OBS1B — 25% — queued after OBS1A.
4. Calendar Android dead-space — 30% — deferred until release-critical gates are stable.

## Closed items that must not be returned to active status without a new reproducible regression

- UX2-F08 — CLOSED — physical iPhone + Android parity verified.
- MON12-AD6 — CLOSED — Android ads physically verified functional on Home + Insights.

## Priority order

P0 — MON12-OBS1A physical Android telemetry closure.
P1 — MON13 fresh physical Android purchase verification. MON14 is CLOSED/PASS.
P1 — MON12-BILL1 Play Console deployment/confirmation.
P2 — MON12-OBS1B.
P2 — Calendar Android dead-space.
P3 — MON15 final two-device end-to-end regression.

### Global invariant — centralized adaptive cross-platform ownership

Progress: 100%

- Applies across the entire Flow Ai application and future releases.
- One authoritative owner is preferred for shared UI, state, services, entitlement logic, design tokens, and behavioral contracts.
- Android and iOS may produce different geometry from the same centralized system.
- Geometry differences must derive from runtime constraints such as viewport, safe area, text scale, accessibility, OS capability, and platform contract.
- Arbitrary per-platform visual patches are prohibited when shared adaptive ownership can express the required behavior.
- Platform-specific logic is permitted only for genuine platform/API differences and must remain behind centralized abstraction.
- Deep audit is mandatory before significant mutations.
- Physical Android and iPhone verification is required before shared cross-platform missions reach 100%.

### MON13/14-C4 — Premium layout balance & alignment

Progress: 100%

Closure evidence:
- Physical iPhone default state approved.
- Physical Android default state approved.
- Complete legal footer is visible.
- Current subscription uses the approved centered vertical hierarchy: title, 42px verification badge, plan, expiry.
- Manage Subscription and Restore Purchases remain one compact action cluster.
- Layout is centrally adaptive from viewport constraints.
- No Android/iOS geometry fork exists.
- Dedicated regression contract locks the approved hierarchy.
- Full Premium regression suite is green.
- Full analyzer is zero-warning.
- Android release build is green.
- iOS release build without codesign is green.

Status: locked for this release. Reopen only for evidenced regression or explicitly approved redesign.


### Identity / Lifecycle Code Checkpoint - VERIFIED

Verified:
- AppLock lifecycle contracts pass
- authenticated greeting identity contracts pass
- legacy identity compatibility no longer fabricates profile attributes
- account deletion requires confirmed backend identity deletion
- account deletion client/backend response contract is aligned
- account deletion regression contracts pass
- Functions deletion/security suite passes 50/50
- Functions runtime-contract test uses compiled JavaScript instead of direct TypeScript import
- module-type warning is removed without changing production module configuration
- targeted Identity Flutter analyzer reports 0 issues

Remaining:
- physical AppLock lifecycle verification on Android and iPhone
- physical greeting verification using the same authenticated account
- final account-isolation release sweep
- controlled physical account-deletion verification using a disposable test account

### Identity Legacy Profile Truth - IMPLEMENTED / PHYSICAL VERIFICATION PENDING

Deep reachability audit found:
- `createMockUser()` had no production caller and contained synthetic profile data
- legacy local-user reconstruction invented age, lifestyle, weight, and height
- `LocalUserService.getUser()` returned null with an unfinished compatibility TODO
- `LocalUserService` itself remains production-reachable for controlled legacy-account compatibility and must not be removed wholesale

Correction:
- removed unreachable mock-user generation
- removed fabricated profile defaults from local-user reconstruction
- implemented truthful LocalUser -> UserProfile compatibility mapping
- unknown profile attributes remain unknown rather than being invented
- real LocalUser identity timestamps are preserved
- account-deletion behavior remains unchanged

Verification:
- release contract added to prevent synthetic identity/profile fallback regression
- physical identity/account verification still required
   - AppLock
   - greeting identity
   - account isolation
   - account deletion regression

4. Cycle / Predictions
   - truthful prediction screen + route
   - centralized calculation authority
   - no synthetic/fake fallback

5. Release Integrity
   - analyzer integrity
   - warning/deprecation cleanup
   - stale-contract reconciliation
   - account-scoping checks
   - reachable mock/dummy/synthetic-data sweep

6. Physical Release Verification
   - Android
   - iPhone
   - Health Connect / HealthKit
   - Premium/store behavior
   - critical UI states

7. Final Gates
   - full tests
   - full analyzer
   - Android release build
   - iOS no-codesign device build
   - diff integrity
   - controlled staging
   - commit
   - push
   - fetch
   - recalculate verified progress

Rules:
- No new branches.
- No duplicate mission plans.
- Update this original master ledger only.
- Keep Immediate Release work separate from deferred/future work.
- Keep each engineering change grouped under its authoritative mission.
- Record every verified finding, blocker, warning, stale contract,
  physical-test requirement, and release decision here.


Smart review and recommendation system:
- Flow Ai requires a centralized cross-platform review/feedback strategy rather
  than scattered or immediate store-review prompts
- first audit and reuse any existing review/rating owner before introducing a
  new service
- review eligibility must be based on meaningful positive product engagement,
  not app launch alone
- suitable signals may include successful completion of valuable user actions,
  repeated healthy engagement, useful insight consumption or other proven
  positive milestones; exact signals and thresholds must be evidence-driven
- never interrupt onboarding, error states, permission requests, checkout,
  account deletion, health warnings or other high-friction/sensitive moments
- respect dismissal and cooldown state and prevent repeated prompting
- native Apple/Google review APIs must remain platform-compliant and the app
  must not assume that calling the API guarantees that a review dialog appears
- provide an explicit user-initiated route to rate/review Flow Ai from an
  appropriate settings/about/help surface
- collect private product feedback separately from public store-review requests;
  do not manipulate ratings or gate review access based on sentiment
- recommendation/referral prompts, if introduced, must be a separate measurable
  engagement flow rather than being conflated with App Store/Play review prompts
- analytics must measure eligibility, prompt request, user action when actually
  observable, cooldown/dismissal and source milestone without fabricating
  unobservable store-review outcomes
- behavior must be verified on both Android and iOS

M3 Google Play Billing Library enforcement gate:
- Google Play Console reports that Flow Ai currently uses an old Google Play
  Billing Library version
- enforcement deadline: 1 November 2026
- every actively published Android update must use Google Play Billing Library
  version 8.0.0 or later
- Google recommends Billing Library 9 for the latest monetization capabilities
- Flutter package version must not be treated as proof of the underlying native
  Billing Library version; compliance is determined from the resolved Android
  release runtime dependency
- all third-party SDKs that transitively include Google Play Billing must also
  resolve to a compliant version
- after correction, a new build must be published to every actively used Play
  track and Play Console must clear the policy issue
- this is a mandatory M3 Monetization / Play release gate, not deferred backlog
- upgrade implementation must first audit plugin/API compatibility, purchase
  acknowledgement, restore behavior, receipt validation and existing tests
  before changing dependency versions

## Current Production Progress

`General 81% I 3/10 Monetization: 84% I 5/10 Identity & Cloud Integrity: 90% I 6/10 Wellness Data Integrity: 88%`

Percentages remain frozen until the defined mission gates are completed and explicitly recalculated.

## Engineering Rules

- Canonical repository: `/Users/ronos/flow_ai_professional_release_20260701`
- Canonical branch: `release/central-integration-20260720`
- Do not create or switch branches unless explicitly instructed.
- Verify repository path, Git top-level, branch, expected HEAD, and worktree before mutation.
- Facts and evidence only.
- Never guess, assume, estimate, invent values, or take shortcuts.
- Use exact measured values, counts, paths, versions, test totals, build output, and physical-device evidence.
- Deep audit before mutation.
- If evidence is incomplete or contradictory, stop and audit deeper.
- Centralize fixes at the authoritative owner.
- Preferred ownership flow: engine/service -> provider/state -> consumers.
- No production mocks, demos, fabricated health values, synthetic predictions, or unsupported UI claims.
- Authorization does not prove health data exists.
- Health data does not prove a wearable is connected.
- Device identity must come from real provenance.
- Do not blindly rerun failed mutations.
- Preserve valid partial work.
- Mutation scripts must be rerun-safe and distinguish OLD, ALREADY CORRECT, ABSENT, and PARTIAL/UNKNOWN states.
- Never use `git add -A`.
- Stage only reviewed release-scope files.
- Relevant release gates require both physical Android and iPhone verification.
- Every unfinished mission, blocker, discovery, and deferred item remains numbered.
- Immediate release blockers outrank future improvements.
- Documentation must follow verified engineering evidence and must not replace execution.

## Status Vocabulary

- PROVEN - directly supported by source, tests, build output, device output, or Git evidence
- IMPLEMENTED - code change exists but final release gates may remain
- VERIFIED - required verification gate passed
- ACTIVE - current work
- BLOCKED - named dependency prevents progress
- PENDING - queued behind higher-priority work
- DEFERRED - intentionally assigned to a later release
- COMPLETE - all defined gates closed
- UNRESOLVED - scope or ownership must be recovered before being restated

## Immediate Release Mission Details - ACTIVE

These are the numbered engineering details and evidence for the single
`IMMEDIATE RELEASE PLAN - ACTIVE` above. This is not a separate plan.

Do not allow future work to interrupt these unless a newly proven release blocker has higher priority.

## P0.1 Android Health Connect Availability - ACTIVE

Proven:
- Physical device ID: `RF8NA1QJR7H`
- Model from ADB inventory: `SM_N770F`
- Android release: `13`
- Flow AI Android package: `com.flowai.app`
- Flutter health package: `health 13.1.4`

Still required:
- exact Android SDK
- exact Health Connect provider/package availability
- exact Flow AI health permissions requested
- exact granted/denied permission state
- real authorization result
- real health-data read or truthful empty-data result

### P0.1d Health Connect UI and Disclosure Centralization - IMPLEMENTED

Implemented ownership:
- `AdvancedBiometricService` owns exact Health Connect SDK availability and install action.
- `HealthProvider` exposes service-owned availability state.
- `HealthKitConnectionCard` renders Android install, unavailable, or normal connect state.
- iOS retains the normal HealthKit connect flow.
- `HealthKitPermissionDialog` is the single Health disclosure owner.
- `Privacy details` uses information-only disclosure mode and does not request authorization.
- the duplicate card-owned disclosure and its stale platform-specific wording were removed.

Physical Android verification remains required before P0.1 is COMPLETE.

### P0.1e Physical Health Disclosure Layout - IMPLEMENTED

Physical Android verification found the disclosure content fit correctly,
but the default AlertDialog action alignment pushed `Not Now` and
`Continue` to the right.

Release fix:
- center the dialog action group
- use equal horizontal action padding
- use balanced minimum touch targets for `Close`, `Not Now`, and `Continue`
- preserve all existing authorization callbacks and disclosure semantics

Daily Feelings dark-mode audit and physical screenshot confirmed its
surfaces are theme-driven. Hard-coded white values are confined to the
colored gradient header and remain intentional.

### P0.1f Central Dialog Action Design - IMPLEMENTED

Physical Android evidence showed the secondary `Not Now` action was
difficult to see at rest in dark mode and visually more oval than the
primary action.

Centralized fix:
- `AppGeometry.radiusSm = 12` owns shared action radius
- `AppGeometry.capsuleHeight = 44` owns shared action height
- `AppTheme.dialogSecondaryActionStyle()` owns secondary action colors,
  outline, surface, and geometry
- `AppTheme.dialogPrimaryActionStyle()` owns primary dialog action style
- `HealthKitPermissionDialog` consumes these shared styles
- `Close`, `Not Now`, and `Continue` no longer define local button geometry

Design rule:
Dialogs and shared UI controls must consume centralized geometry and
theme/component styles unless a documented functional requirement
justifies a deviation.

Physical Android re-verification remains required.

### P0.1G Central Dialog Shell Geometry - IMPLEMENTED

Physical review showed the Health disclosure shell looked sharper than
the intended Flow Ai dialog design.

Verified root cause:
- `AppGeometry.dialogRadius` already defines the shared dialog radius
- AppTheme and the Health dialog still used local `16` px shapes

Correction:
- `AppTheme.dialogShape` is the authoritative dialog shape owner
- it consumes `AppGeometry.dialogRadius`
- Health disclosure consumes the shared shape
- Health-specific size/content constraints remain unchanged

Physical Android and iPhone verification remains required.

Central rounded-rectangle geometry rule:
- Flow Ai shared controls, selectors, roadmap/status badges and similar compact
  UI surfaces use rounded-rectangle geometry by default
- `AppGeometry.radiusSm = 12` is the verified shared small-control radius
- the Q3 2026 roadmap badge already consumes `AppGeometry.radiusSm`
- pill/oval geometry is not the default design language and requires a proven
  functional reason
- the existing symbol `capsuleRadius` currently also resolves to the same
  12 logical-pixel rounded rectangle; renaming that symbol is deferred unless
  required for release because changing naming alone provides no user-visible
  release value

### M6 Health Section Header Hierarchy and Responsiveness - IMPLEMENTED

Physical iPhone verification proved:
- Health section headings were visually weaker than the established Home hierarchy.
- the shared `HealthSectionHeader` used a 20 px icon and `titleMedium`.
- the shared owner forced titles to one line with ellipsis.
- `Symptom Tracker` therefore rendered as `Symptom Tr...` when `Add Symptom` occupied the same row.

Central fix:
- `HealthSectionHeader` remains the single owner.
- leading section icon increased from 20 px to 22 px.
- section title hierarchy increased from `titleMedium` to `titleLarge`.
- hard one-line ellipsis behavior removed.
- header layout changed from forced `Row` competition to responsive `Wrap`.
- trailing actions stay beside the heading when space permits and naturally move to the next run when space is insufficient.
- no hard-coded width breakpoint was introduced.
- metric-card typography and Apple HealthKit hierarchy were intentionally left unchanged.

Physical Android and iPhone verification remains required after this mutation.

## P0.2 Android Health Connect Authorization and Real Reads - PENDING

Required:
- prove real authorization path
- prove exact requested health-data types
- prove permission outcome
- prove real `HealthDataPoint` reads or truthful no-data result
- prove authorization is not treated as data availability
- preserve source/device provenance

## P0.3 iOS HealthKit Physical Production Truth - PENDING

Required:
- release-mode iPhone run
- real HealthKit authorization
- real read or truthful empty-data result
- real provenance where records exist
- no claim of Apple Watch or another wearable without source evidence

Do not classify HealthKit as fully active until these physical gates pass.

### P0.2A Health Data Coverage Typography - IMPLEMENTED

Physical Android evidence showed the Data Coverage value was visually
larger than the Health Connect connection status.

Verified implementation:
- Data Coverage value uses `titleMedium`
- the previous `headlineSmall` value style is removed from that region
- health data calculation and provenance are unchanged

### P0 Brand Casing - IMPLEMENTED

User-visible product branding is standardized to `Flow Ai` in the
currently proven active Health, Analytics, and biometric-authentication
surfaces.

Technical identifiers such as package IDs, Firebase IDs, URLs, source
symbols, and debug-only identifiers are not renamed by this change.

Physical verification remains required.

## P0.4 Active Misleading Health-Score Logic - IMPLEMENTED / FINAL VERIFICATION PENDING

Audit target:
- `HealthProvider._calculateHealthScore()`

Required:
- prove every active consumer
- availability must not be presented as a health rating
- centralize or remove misleading active score logic
- do not delete dormant code before reachability is proven

### P0.4 Health / Analytics Score Truth - CODE CLASSIFIED

Verified release-path ownership:
- Home navigates to `EnhancedAnalyticsDashboardScreen`
- active analytics remain protected by the analytics truth contract
- legacy analytics dashboards are not release-path owners unless a future
  reachability check proves otherwise
- no production consumer of `HealthProvider.healthScore` is currently proven
- biometric model `healthScore` fields are separate model data and are not
  evidence of a `HealthProvider.healthScore` consumer
- Health detail UI continues to present `Data Coverage`, not a wellness rating

The dormant HealthProvider score calculation is not deleted in this mission.
Any future consumer must first define truthful semantics and release coverage.

Physical verification remains part of the final device pass.

## P0.5 Prediction Truth and Navigation - IMPLEMENTED / FINAL VERIFICATION PENDING


### P0.5C Active Prediction Ordering and Anchor Truth - CODE VERIFIED

Verified correction:
- comprehensive prediction statistics normalize cycle records chronologically
- confidence resolves the newest recorded cycle explicitly
- comprehensive predictions fail closed without a recent recorded-cycle anchor
- reference-date-only next-period fallback is removed
- engine truth contract: 2/2 passed
- home prediction truth contract: 2/2 passed
- prediction route truth contract: 1/1 passed
- targeted analyzer: 0 issues

Remaining:
- physical Android prediction verification
- physical iPhone prediction verification


Verified:
- Home consumes centralized `CycleProvider.predictions`
- Home fails closed when prediction is null
- Home navigates to `/predictions`
- `/predictions` routes to `CyclePredictionsScreen`
- active prediction UI consumes `CycleProvider.predictions`
- insufficient history shows a truthful unavailable state
- active route does not use `AIPredictionsScreen`
- active route does not use `PeriodPredictionEngine`
- active route does not use `anonymous_user`
- route and prediction-truth contracts are implemented

Remaining:
- physical Android verification
- physical iPhone verification
- final analyzer/release-contract pass


### P0.5D Recorded-Cycle Next-Period Anchor Truth - CODE VERIFIED

Source semantics:
- `CycleData.complete(endDate)` derives recorded `cycleLength` from
  `startDate` through `endDate`
- menstrual-flow duration is tracked separately as `periodLength`
- therefore cycle `endDate` is not a valid anchor for adding another complete
  average cycle interval

Verified correction:
- next-period prediction is anchored start-to-start from the recorded cycle
- stale start-to-start predictions return unavailable instead of fabricating
  missing intervening cycles
- `_predictNextPeriod()` is nullable by design so the comprehensive prediction
  path can fail closed
- the old `estimatedEnd + averageCycleLength` double-anchor path is removed
- no reference-date-only fallback remains
- chronological interval ordering remains explicit
- confidence remains anchored to the explicitly newest recorded cycle

Verification gates:
- prediction engine truth contract passes
- home prediction truth contract passes
- prediction route truth contract passes
- targeted analyzer passes
- active prediction truth guard passes

Remaining P0.5 work:
- physical Android prediction verification
- physical iPhone prediction verification



### P0.5E AI Reminder Legacy Reachability - DORMANT DEBT

Static production reachability audit verified:
- `AIRemindersService` has no external production imports
- it has no external class references, construction, provider, DI, or locator path
- `calculateNextCycle()` is only called from inside the dormant reminder service
- the dormant service contains hard-coded medication examples, wellness-goal
  defaults, and fixed reminder-time anchors

Release decision:
- these values are not in the active production execution graph
- do not mutate or delete this dormant subsystem during the immediate release
- retain it as legacy synthetic-data debt for the later reachable/dead-code sweep
- active cycle prediction remains owned by `calculatePredictions()`,
  `CycleProvider`, and `/predictions`

Remaining P0.5:
- physical Android prediction verification
- physical iPhone prediction verification


### M6 Health Symptom Chip Dead-Branch Cleanup - VERIFIED

Analyzer warnings at the Health symptom-chip region were classified as
reachable UI containing impossible styling branches.

Evidence:
- `_buildSymptomTracker()` is called from the active Health screen
- every chip set `isActive = false`
- therefore all active-state ternary branches were unreachable

Resolution:
- removed only the impossible active styling branches
- preserved the exact previously rendered inactive appearance
- no symptom data, navigation, Health Connect, or tracking behavior changed

### P0.5B Truthful Prediction Route - IMPLEMENTED

Verified release correction:
- Home `/predictions` navigation now has a real router destination
- route targets `CyclePredictionsScreen`
- screen consumes only `CycleProvider.predictions`
- null predictions fail closed to an unavailable state
- legacy `AIPredictionsScreen`, `PeriodPredictionEngine`,
  `anonymous_user`, and artificial loading delays are not route owners

Physical verification remains required.

## P0.6 Account-Deletion Regression - CODE VERIFIED / PHYSICAL VERIFICATION PENDING

### P0.6 Cloud Deletion Confirmation Contract - RECONCILED

Deep audit proved the production deletion gateway intentionally requires both:
- backend `ok == true`
- backend `identityDeleted == true`

A historical gateway test fixture returned only `ok` and `deletedDocuments`,
so it became stale after identity-deletion confirmation was hardened.

Correction:
- updated the successful test fixture to include `identityDeleted: true`
- added regression coverage proving `identityDeleted: false` is rejected
- production gateway/backend behavior was not weakened or changed

Verified:
- active account-deletion UI path reaches `AuthService.deleteAccount()`
- cloud deletion requires authenticated user ownership
- backend removes premium entitlement/subscription and partner-linked data
- backend confirms Firebase identity deletion
- client rejects responses where identity deletion is unconfirmed
- account-deletion regression contracts pass
- Functions deletion/security suite passes

Remaining:
- controlled physical deletion verification using a disposable test account
- final account-isolation release sweep

### P0.6A App Lock Lifecycle - IMPLEMENTED / PHYSICAL VERIFICATION PENDING

Physical Android testing proved the biometric lock was appearing after
temporary system flows such as Health Connect.

Root cause:
- `MainShell` called `AppLockService.lock()` for `inactive`, `paused`,
  and `detached`
- `resumed` immediately evaluated `shouldRequireLock()`
- `AppLockService` had no background-duration policy
- therefore temporary platform transitions invalidated the unlocked session

Release correction:
- `inactive` is no longer treated as a lock event
- `paused` / `hidden` record central background lifecycle evidence
- `resumed` clears that lifecycle evidence without automatically locking
- `detached` still invalidates the unlocked session
- explicit sign-out/reset/security lock behavior remains intact
- no arbitrary inactivity duration was invented

A future time-based background lock must use an explicitly defined
product/security policy before enforcement.

Physical Android and iPhone verification remain required.

## P0.7 Physical Android and iPhone Verification - PENDING

Android:
- Health Connect authorization and real/no-data behavior
- Health source/provenance
- compact Health disclosure without clipping or overflow
- exactly five disclosed health categories
- `Not Now` and `Continue` behavior
- shortened Health copy remains truthful
- Daily Feelings pure `<`
- Daily Feelings light/dark mode
- no synthetic Home prediction when history is insufficient
- prediction destination never fabricates fallback data

iPhone:
- release mode
- HealthKit authorization and real/no-data behavior
- provenance
- Health UI truth
- Daily Feelings navigation/theme
- prediction truth

### P0.7A Home Greeting Identity + Responsive Header - IMPLEMENTED

Physical comparison showed:
- Android displayed a personal greeting
- iOS displayed only the generic greeting
- the iOS greeting/date area was visibly constrained

Root cause:
- the Home avatar consumed the live authenticated user
- the Home greeting consumed only
  `SettingsProvider.preferences.greetingName`
- this created inconsistent identity timing/state across platforms

Resolution:
- Home now consumes the existing centralized
  `UserDisplayNameResolver.resolveIdentity()`
- authenticated provider identity remains authoritative
- same-account saved identity is allowed as a fallback
- safe email-derived first-name fallback remains centralized
- no platform-specific Android/iOS greeting logic was introduced
- greeting and date are constrained to one responsive line

Physical Android and iPhone verification remain required.

### P0.5 Additional Production Truth Finding - CONFIRMED

### P0.5A Home Synthetic Prediction Remnants - IMPLEMENTED

Reachable Home source contained four `97` fallback arguments attached to
Health Matrix cards.

Audit proved the corresponding `accuracy` parameter was not rendered by
`_buildHealthMetricCard()`.

Resolution:
- preserved the rendered accuracy field
- replaced all reachable `97` fallback arguments with truthful `No data`
- no visible Health Matrix behavior was replaced with invented data
- central `CycleProvider.predictions` remains the prediction owner

The P0.7A audit exposed reachable Home health-matrix fallback strings using
`'97'` when prediction/accuracy values are absent.

This is not part of the greeting mutation.

It was recorded as a P0.5 truth blocker and has since been addressed.
Final physical/release verification must still confirm the corrected behavior.
Any remaining legacy implementation must stay unreachable or be removed only
after reachability is proven. Historical note:
replaced with truthful unavailable/no-data semantics after the prediction
consumer audit proves the authoritative owner.

## P0.8 Final Release Gate and Git Current - PENDING

Required:
1. release contracts
2. full analyzer
3. account-deletion targeted regression
4. Android build
5. iOS release build
6. `git diff --check`
7. `git diff --cached --check`
8. controlled staging
9. staged diff review
10. commit
11. push
12. fetch
13. verify local HEAD equals remote branch HEAD
14. recalculate M6 and General progress

# Mission 6 - Wellness Data Integrity

## 6.C3 Current Subledger

### 6.C3.1 Health Truth and Provenance - IMPLEMENTED

Real health observations and provenance only.

No synthetic production health values.

### 6.C3.2 Home Prediction Data Truth - IMPLEMENTED

Home uses centralized prediction state.

### 6.C3.2a Home Prediction Navigation - IMPLEMENTED / FINAL VERIFICATION PENDING

Home targets `/predictions`, and the truthful destination route is implemented
through the centralized prediction flow.

Verified:
- `/predictions` route is wired
- destination consumes centralized `CycleProvider.predictions`
- unavailable prediction state fails closed when history is insufficient
- legacy anonymous/synthetic prediction fallback is not used by the active route

Physical/final release verification remains required.

Tracked under P0.5.

### 6.C3.3 Daily Feelings Back Control - IMPLEMENTED

Pure chevron `<` implemented.

### 6.C3.4 Daily Feelings Dark Mode - IMPLEMENTED / PHYSICAL VERIFICATION PENDING

### 6.C3.4A Daily Feelings Notes / Done / Save UX - IMPLEMENTED

- Notes keyboard action is Done
- editing Notes hides Save
- Done dismisses the keyboard and reveals Save
- redundant save-success feedback removed
- save-error feedback and persistence remain unchanged
- physical Android+iPhone verification pending

Physical dark-mode review reopened this mission because the top header
remained permanently bright and inactive tab labels lacked sufficient
contrast.

Current correction:
- feature-header gradient is centrally brightness-aware
- dark mode uses the existing centralized dark background gradient
- light mode preserves the existing branded Flow Ai gradient
- inactive segmented-tab text uses a centralized contrast-aware owner
- body surfaces remain theme-driven
- no unrelated screens were restyled

Physical Android and iPhone light/dark verification remains required.

### 6.C3.5 Health Wording Compaction - IMPLEMENTED

Rules:
- preserve source/access/data truth
- coverage means availability, not health quality
- reduce repetition
- avoid semicolons in user-facing Health copy
- use periods, colons, or dashes

### 6.C3.6 Health Disclosure Compaction - IMPLEMENTED

Central owner:
`lib/features/health/widgets/healthkit_permission_dialog.dart`

Measured implementation:
- max content width: `440` logical px
- max content height: `52%` of viewport height
- dialog inset: `24` logical px horizontal and vertical
- exactly five categories preserved

Categories:
1. Heart rate and HRV
2. Body temperature
3. Sleep
4. Activity and steps
5. Menstrual flow

`Not Now` and `Continue` behavior must remain unchanged.

### 6.C3.6A Android Health Connect Production Integrity - ACTIVE

Tracked by P0.1 and P0.2.

### 6.C3.6B iOS HealthKit Production Integrity - ACTIVE

Tracked by P0.3.

### 6.C3.6C Physical Health Source and Device Provenance - PENDING

Rules:
- permission granted does not mean data exists
- data exists does not mean a wearable is connected
- never name a wearable/device without actual provenance

### 6.C3.7 Prediction Centralization and Truthful Route - IMPLEMENTED / FINAL VERIFICATION PENDING

Tracked by P0.5.

Central model:
`CyclePredictions`

Central provider:
`CycleProvider.predictions`

Legacy-only values without an authoritative central equivalent must be removed or shown unavailable.

### 6.C3.8 Controlled Staging and Final Release Gates - PENDING

Tracked by P0.8.

### 6.C3.9 Percentage Recalculation - PENDING

Do not change frozen percentages before verified closure.

# Major Mission Map

## M1 Deep-Link and Invite Flow

Historical implementation completed.

Current release revisit:
- `M1-R` for current deep-link/store compliance if proven relevant

## M2 Identity and Sign-In Recovery

Historical mission completed.

New regressions must become new numbered subtasks.

## M3 Monetization

Progress frozen at `84%`.

Current release-relevant work:
- real Play/App Store catalog verification
- real physical purchase and restore verification
- backend entitlement/refund/revocation verification
- AdMob optimization remains centralized under M3.10

M3 is a mandatory immediate-release gate and must be completed before final release closure.

### M3.10 AdMob Revenue Optimization - PLANNED

Goal: increase sustainable ad revenue without degrading Flow Ai health UX,
retention, privacy, or Premium conversion.

1. Rewarded ads
   - opt-in only
   - use for genuine optional value
   - never gate essential health/cycle functionality

2. Impression policy
   - centralize ad frequency and placement ownership
   - use natural navigation/content boundaries
   - prevent impression flooding

3. Retention-first optimization
   - measure retention/session behavior before increasing frequency
   - monitor dismissals, session exits, and ad-driven abandonment

4. Placement optimization
   - define eligible and prohibited surfaces centrally
   - no ads during permissions, health-data connection, symptom entry,
     sensitive health information, or purchase/restore flows

5. Geography analytics
   - measure country-level fill rate, eCPM, impressions, and revenue
   - use measured performance for acquisition/marketing decisions
   - do not fabricate targeting assumptions

6. Frequency caps
   - session and time-based caps
   - rewarded, interstitial, and banner policies remain independent

7. Privacy and consent
   - GDPR/UMP and platform consent remain authoritative
   - ATT requirements respected where applicable

8. Revenue telemetry
   - impressions
   - fill rate
   - eCPM
   - estimated revenue
   - format
   - placement
   - country where legitimately available
   - Premium conversion interaction

9. Premium protection
   - Premium entitlement remains ad-free according to product policy
   - ads must not interfere with subscription purchase/restore validation

10. Controlled experimentation
   - remote-configurable placements/frequency only after baseline truth
   - safe defaults
   - rollback capability
   - no hard-coded aggressive ad strategy

Release priority:
Complete purchase/receipt/entitlement correctness first. Ad revenue
optimization follows within M3 before final monetization closure where safe.

#### M3.10A Future GMA SDK Coarse-Location Readiness - PLANNED

AdMob notified publishers that a future Google Mobile Ads SDK release can
collect device coarse location when the app already has user-granted location
permission.

Flow Ai release policy:
- never request location permission solely to improve advertising
- first prove whether any active Flow Ai product feature genuinely requires location
- when the new GMA SDK is considered, audit the exact SDK version and release notes
- audit Android and iOS location permission ownership before upgrading
- audit UMP/GDPR/ATT/privacy disclosures before enabling any new collection
- inspect and centralize the GMA coarse-location configuration flag
- default to disabling ad-related coarse-location collection unless there is a
  proven product/legal reason to enable it
- preserve user consent signals and platform privacy requirements
- update the public privacy policy before enabling newly collected data
- add release contracts/configuration guards so location behavior cannot change silently

Revenue strategy:
- geographic monetization analytics may measure legitimate country-level
  performance where available
- do not obtain additional permissions merely to chase higher-eCPM markets
- prioritize rewarded ads, retention, mediation, placement quality, Premium
  conversion, and acquisition efficiency

Status:
- future SDK capability; not active until Flow Ai adopts the relevant GMA SDK
- no production permission/configuration mutation required yet


#### M3.11 Google Play Search Conversion Optimization - ACTIVE

Google Play surfaced a measurable acquisition opportunity for the search term
`flow ai`.

Current evidence:
- custom store listing reference: `flow ai_search custom listing`
- target keyword: `flow ai`
- listing rollout: 50%
- current keyword conversion rate: 13%
- current average app conversion rate: 14%
- listing has no fixed end date

Primary objective:
Raise conversion for `flow ai` searches above the current 14% app-wide
baseline without misleading health or AI claims.

Current optimization plan:
1. preserve the 50% rollout initially so listing performance can be compared
   against the inherited/default listing
2. shorten and sharpen the short description
3. reduce repetitive AI/health marketing language in the full description
4. lead with the concrete user benefit:
   health trends, wellness tracking, cycle/wellness understanding, and privacy
5. keep medical/wellness disclaimers accurate and visible
6. ensure screenshots communicate product value faster than prose
7. audit first screenshot, feature graphic, icon, and screenshot sequence
8. measure custom-listing conversion against the current 13% baseline
9. do not move to 100% rollout merely because traffic increases; require
   measured conversion improvement
10. use Play acquisition/conversion evidence to guide subsequent listing tests

Success gates:
- conversion exceeds 14% baseline
- no increase in misleading health/medical claims
- listing assets match the current production Flow Ai UI
- listing promises only functionality verified in the production app

Relationship to monetization:
Better store conversion increases installs and feeds the M3 monetization
funnel, but conversion optimization does not replace retention, Premium,
AdMob, rewarded ads, or revenue-per-active-user optimization.


## M4 Analytics Integrity

Historical mission completed.

Synthetic or misleading active analytics discovered later are owned by M6 truth work.

## M5 Identity and Cloud Integrity

Progress frozen at `90%`.

Remaining release-relevant identity/cloud work resumes after current P0 blockers unless it directly blocks release.

## M6 Wellness Data Integrity

### M6 Immediate Release Checkpoint - CODE / CONTRACT VERIFIED

Current verified release evidence:
- targeted M6 analyzer: 0 issues
- 8/8 active M6 contract files passed
- supporting no-synthetic-health fallback contract reconciled to current production truth
- stale `final isActive = false;` expectation removed from the historical contract
- unused/deprecated M6 analyzer findings were resolved
- Health implementation was not regressed to satisfy stale tests
- M6 work remains physically unclosed until Android and iPhone verification completes

Remaining M6 release gates:
- Health screen compaction physical verification
- Symptom Tracker dark-mode physical verification
- Daily Feelings dark/light + Notes Done/Save physical verification
- Android Health Connect final physical verification
- iOS HealthKit production physical verification

Progress frozen at `88%`.

Current primary mission.

### M6-C3.6E Contract / Analyzer Integrity Reconciliation - VERIFIED

Purpose:
Keep M6 Wellness evidence aligned with the current production implementation
and prevent stale tests or analyzer warnings from forcing regressions.

Verified findings:
- M6 targeted analyzer reached 0 issues.
- Eight active M6 release-contract files passed.
- A stale historical contract,
  `mission5_no_synthetic_health_fallbacks_test.dart`,
  still expected `final isActive = false;`.
- That implementation had already been correctly removed because it created
  unreachable styling branches and analyzer warnings.
- The production Health implementation was not changed to satisfy the stale
  assertion.
- The contract was reconciled to verify the current truth instead:
  no fixed inactive-state variable and no mock/dummy/synthetic Health fallback.
- Warning cleanup also removed:
  - unused `_buildLegendItem`
  - unused Health dashboard imports
  - deprecated `withOpacity()` calls in the biometric pulse indicator
- Health source remains fail-closed and truthful for missing data.

Engineering rule established:
- analyzer warnings are treated as unresolved until classified
- test failures are classified as implementation defect, stale contract,
  environment/tooling issue, or expected negative-path behavior
- stale tests must be updated to current production truth rather than
  reintroducing dead or misleading code
- every mission gate must inspect process exit code and explicit success markers
- expected test names containing words such as `failed` must not trigger false
  failure detection

Status:
- M6 contract/analyzer integrity: VERIFIED
- M6 physical Android verification: still required
- M6 physical iPhone verification: still required
- Health screen visual compaction physical review: still required
- Symptom Tracker dark-mode physical review: still required


### M6-C3.5 Health Dashboard Information Architecture - CODE VERIFIED / PHYSICAL VERIFICATION PENDING

Physical dark-mode evidence shows the Health screen does not currently match
the compact information hierarchy already established on Home.

Observed physical UI findings:
- Home groups related metrics inside a single authoritative parent dashboard
  container with compact title/subtitle hierarchy
- Health currently fragments related information across multiple independent
  containers:
  Health Overview, Health Connect, Data Coverage, Biometric Monitoring,
  Health Insights, and Symptom Tracker
- Health Connect repeats the same access state through both
  `Access Granted` and `Access granted`
- Health Connect explanatory copy consumes excessive vertical space
- Data Coverage is visually detached from the connection/data-source state it
  describes
- biometric tiles are visually related but not enclosed in the same dashboard
  hierarchy as connection and coverage
- Health Insights uses another standalone large empty-state container
- Symptom Tracker dark-mode text/chip contrast is visibly inadequate
- the Health page therefore reads as stacked independent widgets rather than
  one coherent health dashboard

Required correction:
1. preserve `Health Overview` as the primary page/dashboard owner
2. consolidate Health Connect status, data coverage, and biometric metrics
   into one coherent larger dashboard container where source ownership permits
3. retain compact title + short subtitle language matching Home
4. show the access state only once
5. reduce explanatory copy to concise truthful status text
6. keep `Data Coverage` truthful and visually associated with synced-data state
7. retain biometric metric tiles as compact child tiles inside the health
   dashboard hierarchy
8. keep Health Insights compact, particularly when no observations exist
9. correct Symptom Tracker dark-mode text and chip contrast through the
   centralized theme owner
10. reuse shared geometry, spacing, typography, card and tile owners rather
    than creating Health-only one-off styles

Truth constraints:
- no synthetic health observations
- no fabricated coverage or metric values
- no visual state may imply wearable/Health Connect data exists when it does not
- `No data` / unavailable states must remain explicit
- connection authorization and actual observation availability remain separate
  concepts

Release gates:
- authoritative widget/layout ownership audited before mutation
- Health layout uses centralized shared geometry/theme owners
- dark and light mode verified
- Android physical verification
- iPhone physical verification
- targeted contracts/analyzer green


Final code-side verification:
- stale Mission 5 health contract now verifies absence of the obsolete
  `final isActive = false;` fallback
- no production code was restored or weakened to satisfy the legacy contract
- Health hierarchy contract passes
- relevant Health/Wellness release contracts pass
- targeted analyzer reports 0 issues
- connection status uniqueness remains verified
- Health no-data presentation remains truthful

Only remaining M6-C3.5 gates:
- Android dark-mode physical verification
- Android light-mode physical verification
- iPhone dark-mode physical verification
- iPhone light-mode physical verification


### M6-C3.6 Daily Feelings and Symptom Interaction UI - CODE VERIFIED / PHYSICAL VERIFICATION PENDING

Physical iPhone dark-mode findings:
- Daily Feelings leading face icon is monochrome and does not match the
  established colorful Flow Ai feature-icon language
- `Symptoms` is visibly truncated in the Mood/Energy/Symptoms/Tags selector
- `Not recorded` states are truthful and must remain unchanged until the user
  records values
- overall wellbeing and individual feeling controls correctly begin without
  fabricated scores
- spacing/card hierarchy requires comparison with the centralized Home design
  language before modification
- bottom content requires safe-area and persistent-navigation overlap
  verification
- Symptom Tracker `Add Symptom` would benefit from a small leading action icon
  subordinate to the primary Symptom Tracker icon
- symptom chips remain visually pill/oval shaped and must be reconciled with
  the centralized rounded-rectangle geometry used elsewhere in Flow Ai

Required correction:
1. keep Daily Feelings data semantics truthful; no default wellness scores
2. use the shared Flow Ai feature-icon visual language for the Daily Feelings
   leading icon
3. preserve platform-stable icon rendering rather than depending on emoji-font
   appearance
4. resolve `Symptoms` truncation responsively rather than shortening labels
   arbitrarily
5. audit selector geometry, cards, spacing, radii, typography and safe-area
   behavior against centralized app owners
6. add a small centralized leading icon to `Add Symptom` if the existing
   action-button system supports it
7. replace symptom pill geometry with the app-wide rounded-rectangle owner
8. verify dark/light modes on Android and iPhone
9. do not introduce one-off Health/Daily-Feelings design constants

Release gates:
- authoritative Daily Feelings widgets identified
- shared theme/geometry/icon owners proven
- no synthetic/default emotional-health values introduced
- responsive selector verified without truncation
- Android dark/light physical verification
- iPhone dark/light physical verification
- targeted contracts/analyzer green


Daily Feelings selector interaction requirement:
- `Mood`, `Energy`, `Symptoms`, and `Tags` must display their complete labels
  on every supported screen width
- labels must never be shortened or clipped to solve layout constraints
- selector items must use centralized rounded-rectangle geometry rather than
  local oval/pill geometry
- selector must support horizontal swipe/scroll whenever its intrinsic width
  exceeds the available viewport
- the associated content should support coherent swipe navigation when the
  authoritative screen architecture permits it, with selector and page state
  synchronized from one owner
- tapping a selector item and swiping between content pages must produce the
  same selected state
- selected/unselected appearance must use centralized theme ownership
- no duplicate Daily Feelings selector implementation should be introduced;
  first prove the production runtime owner and reuse an existing shared
  component if one exists
- physical Android/iPhone dark/light verification remains mandatory


Daily Feelings centralized selector verification:
- production runtime owner is
  `lib/features/tracking/screens/enhanced_daily_feelings_tracker.dart`
- fixed-width `TabBar` selector removed from the active screen
- shared `AppSegmentedSelector` owns full-label horizontal selector behavior
- `Mood`, `Energy`, `Symptoms`, and `Tags` retain their complete wording
- selector scrolls horizontally rather than compressing labels
- selector rounded-rectangle geometry uses centralized `AppGeometry.radiusSm`
- tap selection and horizontal content swipe both use the same
  `_tabController`
- content remains natural-height through `AnimatedSwitcher`; no guessed
  PageView height or fixed content viewport was introduced
- Daily Feelings header now uses a color emoji glyph rather than the
  monochrome white face icon
- truthful unrecorded state remains null/empty and displays `Not recorded`
- dedicated release contract passes
- targeted analyzer passes

Physical verification remaining:
- selector full labels on narrow Android and iPhone widths
- horizontal selector scrolling
- left/right content swipe synchronization
- dark/light selected and unselected contrast
- colored Daily Feelings face rendering on both platforms
- no overflow or bottom-navigation collision


Cross-platform biometric parity gate:
- Flow Ai is cross-platform; no Health metric may be declared release-complete
  from evidence on only Android or only iOS
- every user-visible biometric must be audited independently from UI through
  provider/service/platform permission/native source to rendered value
- current exposed metrics include Heart Rate, Temperature, Sleep and Stress;
  additional exposed metrics discovered during audit are included automatically
- Heart Rate must remain data-backed and requires provenance verification for
  source name/device identifier/model and observation timestamp before claiming
  wearable origin
- Sleep must be verified on Apple HealthKit and Android Health Connect with
  truthful duration semantics
- Temperature must be verified independently on both platforms; unsupported or
  unavailable platform/source states must remain truthful `No data`
- Stress must not be inferred merely because HR/HRV data exists; if there is
  no validated production stress computation or platform-backed stress metric,
  the UI must not imply that Stress Level is operational
- platform capability, permissions, retrieval, aggregation, freshness,
  provenance and UI rendering are separate release gates
- no synthetic biometric values or cross-platform assumptions are permitted
- Android and iPhone physical verification remains mandatory before M6 closure


Stress Level active-screen finding:
- physical/source audit proves the active Health screen currently renders
  `Stress Level` as a static `No data` placeholder
- stress/HRV calculations exist elsewhere in the repository, but their
  production reachability into `HealthProvider` / `BiometricSnapshot` /
  `HealthScreen` is not yet proven
- existence of an HRV algorithm is not evidence that Stress Level works on
  Apple HealthKit or Android Health Connect
- do not expose a computed stress value until input provenance, algorithm
  semantics, platform parity and runtime ownership are verified
- if no validated cross-platform production path exists before release, the
  Health screen must fail closed rather than imply that Stress Level is active


### M6-C3.8 Health Clinic Integrity Audit - ACTIVE

Verified findings:
- canonical active Health UI path consumes Heart Rate and Body Temperature
- `BiometricSnapshot` also carries Resting Heart Rate, HRV, Sleep Hours, Steps,
  Active Energy, Blood Oxygen and Respiratory Rate, but the active Health screen
  does not currently render those fields
- `Sleep Quality` is a static `No data` UI placeholder despite real
  `snapshot.sleepHours`; this is a release-visible P1 defect
- `Stress Level` is a static `No data` UI placeholder and there is no validated
  `BiometricSnapshot.stressLevel`; do not invent or arbitrarily connect a stress
  score
- Health Insights UI currently renders a local static `No insights yet` item and
  does not consume the biometric-insight pipeline
- `_saveBiometricInsights()` currently logs a save operation but performs no
  persistent write; it must not be treated as persistence
- Health Goals renders from an explicitly empty local goals list and must remain
  hidden until a real authoritative goals source exists
- body and basal body temperature currently resolve from the same
  `BODY_TEMPERATURE` stream; semantic duplication must be resolved before
  presenting them as distinct measurements
- hourly service sync fetches/caches data, but UI/provider refresh after periodic
  sync remains an explicit verification gate
- overlapping biometric engines/screens must be classified as active dependency,
  dormant legacy or isolated subsystem before consolidation/deletion
- analyzer baseline is clean

Release classification:
P0:
- any false connection/authorization state
- any synthetic health value
- any user-visible metric claiming functionality without a validated pipeline
- Stress Level placeholder if presented as an operational metric

P1:
- render real Sleep Hours/Duration instead of hard-coded `No data`
- hide orphan Health Goals
- connect Health Insights only to real persisted/reachable insight state, or
  keep a truthful empty state without implying generated insights exist
- verify periodic sync refreshes authoritative provider/UI state
- preserve provenance/freshness for every displayed biometric
- reconcile temperature semantics
- verify every displayed metric independently on Android Health Connect and iOS
  HealthKit

Working but physical verification pending:
- Heart Rate pipeline
- Body Temperature pipeline
- Health access/connection truth
- metric provenance/freshness

Dormant/deferred until reachability proves otherwise:
- alternate biometric dashboards/engines not on the active Health route
- analytical insight engines that are not consumed by current production UI


M6 placeholder preservation policy:
- intentional Health feature placeholders must NOT be removed merely because
  their full production pipeline is unfinished
- Stress Level, Health Insights, Health Goals and similar planned feature shells
  remain present unless a separate product decision explicitly removes them
- placeholders must remain truthful and visually distinguishable from live data;
  acceptable states include `No data`, `Not available` or an equivalent honest
  inactive state
- never fabricate biometric values, generated insights, goals or completion
  states merely to populate a placeholder
- clinic audit must classify each placeholder as live-data-backed,
  data-unavailable, implementation-pending or physically-unverified
- when its production pipeline becomes available, replace the placeholder value
  through the authoritative data owner without redesigning/removing the feature
  unnecessarily
- this policy supersedes the earlier proposed approach of hiding unfinished
  Health placeholders


Upcoming feature adaptive sizing rule:
- Health upcoming-feature indicators must reuse the established Home Premium
  Features visual language, but must NOT copy Home tile dimensions blindly
- first measure the authoritative Home tile badge/icon/status/padding/radius
  values and the active Health card dimensions
- Health adaptation must preserve visual hierarchy proportionally inside the
  smaller Health cards
- quarter badge, icon and `Coming Soon` status must remain subordinate to the
  primary metric/feature label and must not reduce available label width enough
  to cause truncation
- exact badge/status dimensions must be derived from the real Health card
  constraints and centralized design owners, not estimated
- if a reusable Home badge/status component already exists, reuse it; otherwise
  centralize the presentation primitive before applying it to Health
- physical verification on narrow iPhone and Android layouts is required before
  accepting the adapted sizing


Upcoming-feature status/size audit findings:
- Home Premium feature grid uses `childAspectRatio: 0.85`
- active Health biometric grid uses `childAspectRatio: 1.1`; Home tile
  dimensions therefore must not be copied directly into Health
- Health biometric cards currently use 16 logical-pixel internal padding,
  24 logical-pixel metric icons and an existing compact top-right status area
- Health status area currently requires verification for unconditional rendering
  when its status string is empty; screenshot/source evidence suggests this is
  responsible for the visible empty status dash
- Home `PremiumFeaturePreviewCard` couples `Coming Soon` state to the literal
  `estimatedDate == 'Q2 2026'`; this is incorrect ownership because roadmap
  quarter and feature availability status are separate facts
- changing AI Health Coach to Q4 2026 must therefore also correct the central
  status semantics rather than merely replacing the quarter string
- repository contains multiple Coming Soon/card implementations; do not create
  another presentation primitive until reachability and authoritative ownership
  are classified
- Health Q3 upcoming indicators must preserve the Health tile's measured
  constraints and only reuse the Home visual language, not its dimensions


Health biometric status-owner checkpoint:
- `_buildBiometricCard` is the authoritative owner for metric-card status
  presentation
- the previous implementation rendered a status container unconditionally even
  when all four callers supplied an empty status string, producing the visible
  empty status dash
- status is now optional and the status widget renders only for a non-empty
  value
- Heart Rate, Temperature, Sleep and Stress callers no longer pass meaningless
  empty status strings
- no Q3 badge dimensions have been guessed; Health source proves a two-column
  grid, 16 spacing, 16 card padding and childAspectRatio 1.1, but actual card
  width remains viewport-dependent
- Q3 / Coming Soon layout must therefore be validated against real available
  card width or a responsive LayoutBuilder before it is attached to smaller
  Health metric cards


Health Q3 integration exact-owner gate:
- previous Q3 Health mutation stopped before writing because the expected
  existing status guard was not present in the live `_buildBiometricCard`
  structure
- no Q3 sizing or placement is accepted from assumption
- `_buildBiometricCard` remains the authoritative compact biometric-card owner
  and must be structurally reconciled before Stress receives Q3 2026 /
  Coming Soon presentation
- Heart Rate and Temperature remain classified as functioning/data-backed and
  must never inherit upcoming-feature state
- Sleep remains a functioning pipeline with a UI rendering defect and therefore
  must not be classified Coming Soon
- Health Insights and Health Goals retain their placeholders but use different
  full-width geometry from biometric tiles; their upcoming presentation must be
  adapted independently through the same centralized status primitive
- exact source structure, actual constraints and existing shared status owners
  are mandatory evidence before the next mutation


Upcoming status compile gate:
- Home Premium grid now imports the centralized upcoming-feature status owner
- AI Health Coach remains Q4 2026 + Coming Soon
- Stress Level remains Q3 2026 + Coming Soon
- Heart Rate, Temperature and Sleep remain outside upcoming-feature state
- targeted upcoming-status contract passes
- targeted Home/Health analyzer passes

Compact Health roadmap resolution:
- physical Android evidence had shown a 3.6 logical-pixel right overflow when
  the compact Stress tile rendered both Q3 2026 and Coming Soon
- centralized `AppUpcomingFeatureStatus` now suppresses the Coming Soon row
  when `compact == true`
- compact Stress therefore renders Q3 2026 only
- non-compact upcoming feature presentation still supports roadmap quarter +
  Coming Soon, preserving the Home AI Health Coach Q4 2026 presentation
- targeted compact-status release contract passes 3/3
- targeted Home/Health analyzer passes with 0 issues
- physical Android verification remains the final closure gate for this
  observed overflow defect

Biometric-card audit parser correction:
- `_buildBiometricCard` uses named parameters with `{ ... }`; earlier audit
  extraction incorrectly treated the named-parameter brace as the function-body
  brace and therefore returned only the signature
- audit tooling now balances the complete parameter list first and locates the
  actual function body afterward
- physical iPhone evidence remains authoritative: biometric header Row had
  exactly 120 logical pixels available and overflowed by 13 pixels
- centralized roadmap status now participates in the available Row width through
  Flexible/end alignment instead of competing at unrestricted natural width
- compact roadmap padding is reduced centrally from 6 to 4 logical pixels
- no Android/iOS fixed-width override was introduced
- this remains open until both physical Android and iPhone builds show zero
  RenderFlex overflow

Compact biometric roadmap final decision:
- physical Android and iPhone evidence proved that Q3 2026 does not fit
  reliably in the active two-column biometric tile header
- the prior Flexible correction removed RenderFlex overflow but caused the
  roadmap label itself to truncate on both platforms
- roadmap metadata is therefore removed from compact biometric tiles for the
  immediate release
- compact biometric cards prioritize metric truth and readable labels rather
  than release-roadmap presentation
- Stress Level uses `Not available` because no validated production Stress
  snapshot pipeline exists
- Heart Rate, Temperature and working Sleep use real values or `No data`
- Q3/Q4 roadmap presentation remains available only on larger feature surfaces
  whose measured layout supports it
- no font shrinking, clipping, fixed platform width or enlarged biometric grid
  was introduced to force roadmap text into the tile

Sleep UI authority audit:
- `BiometricSnapshot.sleepHours` is the authoritative Health-screen sleep
  duration source
- `AdvancedBiometricService` derives sleep duration from observed sleep
  intervals using their recorded start/end timestamps
- the active Health tile still presents `Sleep Quality / No data` and does not
  consume `snapshot.sleepHours`
- this is a UI truth defect, not an upcoming-feature placeholder
- the release correction must render `Sleep Duration` from the real snapshot and
  retain `No data` only when no usable sleep observation exists
- Android Health Connect and iOS HealthKit physical verification remain required
  after the code correction

Sleep Duration production UI correction:
- active Health biometric tile now reads real
  `BiometricSnapshot.sleepHours`
- user-visible label changed from unsupported `Sleep Quality` to
  `Sleep Duration`
- value is displayed in hours from the authoritative sleep interval aggregate
- `No data` remains the fail-closed state when the snapshot contains no usable
  sleep observation
- no synthetic, default or placeholder sleep duration is introduced
- Sleep is not an upcoming feature because its HealthKit/Health Connect
  production pipeline already exists
- Android and iPhone physical verification remain required for final closure

Stress roadmap presentation correction:
- Stress Level keeps the same truthful `No data` state used by the other
  biometric cards
- the temporary `Not available` wording was rejected and removed
- Stress keeps the Q3 2026 roadmap badge only
- compact mode continues to suppress the separate Coming Soon row
- the shared compact badge was tightened centrally without changing Health
  card dimensions or the larger Home upcoming-feature presentation
- Android and iPhone physical verification remain required before closure

Cross-platform responsive UI follow-up priority:
- Android and iOS must be treated as separate physical layout/runtime targets
  even when they share centralized Flutter components
- Sleep Duration production UI is already present and must not be reworked
  without new contrary evidence
- Stress Q3 2026 / No data code is analyzer-clean; physical Android+iPhone
  re-verification remains pending after the latest compact badge adjustment
- Home greeting physical evidence differs across devices: one layout preserves
  the waving-hand emoji while another ellipsizes the greeting; authoritative
  text/constraint ownership must be reconciled responsively
- Symptom Tracker title wraps on the narrower iPhone layout while Android keeps
  it on one line; exact title/action width ownership must be fixed rather than
  shrinking typography blindly
- symptom chips still require centralized rounded-rectangle geometry
- Health Goals is visually obstructed near the persistent bottom navigation on
  iPhone; safe-area/scroll-bottom ownership must be audited and corrected
- no platform-specific fixed width may be added unless physical evidence proves
  that a native layout difference genuinely requires it

Health connection-card Android/iOS parity finding:
- physical Android and iPhone evidence proves the active health connection
  presentation is not visually equivalent across platforms
- iOS connected HealthKit presentation is substantially shorter and cleaner,
  while Android disconnected Health Connect presentation adds a separate
  `Uses Android Health` badge, longer explanatory copy and a large connection
  action, increasing vertical density
- platform-specific wording and native actions are expected, but card hierarchy,
  spacing, geometry, status placement and information density must come from one
  centralized connection-card design
- Android must not copy Apple-specific wording and iOS must not copy
  Health-Connect-specific wording
- connected/disconnected states must be audited separately on both platforms
  before mutation
- the authoritative connection-card owner and existing centralized button/badge
  components must be reused rather than creating Android-only/iOS-only layouts
- both physical Android and iPhone remain mandatory verification targets

Health connection-card centralized parity correction:
- physical comparison originally showed Android disconnected Health Connect
  against iOS connected HealthKit; state-specific action height is therefore
  expected and must not be mistaken for a purely platform-specific defect
- source audit nevertheless proved redundant Android-only presentation:
  `Uses Android Health` duplicated the already-visible Health Connect identity
- the centralized connection card now uses the platform name itself as the
  heading on both connected and disconnected states; Connect remains an action,
  not part of the section title
- Android-only disclosure badge is removed
- explanatory copy uses one concise hierarchy while retaining Apple Health /
  Android Health source terminology
- Privacy details and connection-card compact geometry use centralized
  rounded-rectangle geometry rather than local 999-radius pills
- Health Connect install/update and unsupported-device recovery states remain
  intact
- connected/disconnected states must be physically checked independently on
  Android and iPhone before this parity action closes

Health connection copy parity rule:
- source audit proved Android disconnected and iOS connected states used
  different explanatory sentence structures
- connection explanation is now one centralized cross-platform template:
  `Flow Ai can read the health data you choose to share through <source>.`
- iOS substitutes `Apple Health`; Android substitutes `Android Health`
- the previous longer Android-only `Allow Flow Ai to read supported health
  data...` sentence is removed
- the previous grammar error `you chose to share` is corrected to
  `you choose to share`
- native connection state remains communicated separately through Access
  granted / Connect / Disconnect controls
- shared wording should remain equivalent across Android and iOS unless a
  platform API requires materially different disclosure

Stress Q3 natural-width correction:
- physical truncation remained because the trailing Q3 badge was still wrapped
  in `Flexible` after an existing `Spacer`
- source proved the active header pattern was icon -> Spacer -> Flexible badge
- the badge is now natural width after the existing Spacer, matching the proven
  Home trailing-badge alignment model without copying Home card dimensions
- no guessed left offset, clipping, font shrinking or platform-specific width
  was introduced
- current compact padding/text density is intentionally left unchanged for this
  physical verification so only one variable is tested
- Android and iPhone physical verification remain required

Health connection action-copy rule:
- platform identity is presented once in the connection-card title:
  `Health Connect` on Android and `Apple HealthKit` on iOS
- the normal disconnected primary action is simply `Connect`
- the connected action remains `Disconnect`
- `Install Health Connect` remains distinct because it is a recovery/install
  action rather than the normal connection action
- duplicated copy such as `Connect Health Connect` is prohibited
- Android and iOS share the same information hierarchy while preserving their
  native platform names and recovery requirements

Health access dialog cross-platform visual verification:
- physical Android and iPhone evidence shows the Health data access dialog now
  follows the same Flow Ai hierarchy on both platforms
- platform identity remains native: `Health Connect` on Android and
  `Apple HealthKit` on iOS
- core explanation, shareable-data list, privacy notice and Continue / Not Now
  actions are visually equivalent
- only the native settings guidance differs, as required by Android/iOS
- normal connection CTA is centralized to `Connect`; connected CTA remains
  `Disconnect`; Health Connect installation recovery remains separate
- connection action-copy contract passes 3/3 and analyzer reports 0 issues

Health connection CTA owner disambiguation:
- source audit found two independent full-width button owners in the health
  connection card
- one owner is the normal Connect / Disconnect action
- the second belongs to Health Connect installation/recovery and must remain
  independent
- only the normal Connect / Disconnect action is centered at 70% of available
  card width
- recovery/install action sizing is unchanged
- the mutation was applied only after exact owner classification; no broad
  full-width replacement was performed
- Android and iPhone physical verification remain required

Health access dialog action-width finding:
- physical iPhone review shows the Not Now / Continue pair is readable and
  functional but visually narrower than the available dialog width
- preferred release refinement is a modest proportional width increase rather
  than a 30% enlargement
- target is equal-width actions occupying approximately 78-82% of usable dialog
  width while preserving the existing action gap and button height
- implementation must use the authoritative dialog layout owner and responsive
  parent constraints rather than fixed Android/iOS pixel widths
- Android and iPhone must be physically verified independently before closure

Health connection/dialog final hierarchy refinement:
- physical iPhone disconnected evidence still showed `Connect Apple HealthKit`
  as the card heading while the primary action separately showed `Connect`
- platform identity and action semantics are now separated: card heading is
  `Apple HealthKit` / `Health Connect`; primary disconnected action is `Connect`
- physical permission-dialog review showed Not Now / Continue could use more
  horizontal presence while their height, typography and centralized styles
  were already acceptable
- permission actions retain equal dimensions and centralized primary/secondary
  styles
- Android and iOS use the same dialog action geometry and must be physically
  verified independently for wrapping, clipping and balance

Connection-title verification correction:
- a previous gate incorrectly reported the disconnected connection-card title
  as platform-only while source still contained
  `hasAccess ? platformName : 'Connect $platformName'`
- this caused disconnected cards to retain duplicated titles such as
  `Connect Apple HealthKit` / `Connect Health Connect`
- authoritative title rendering is now platform identity only:
  `Apple HealthKit` on iOS and `Health Connect` on Android
- Connect / Disconnect remain action labels only
- release contracts now explicitly forbid the duplicated title expression so
  this regression cannot pass source verification again

Connection-title interpolation gate correction:
- source still contained `Connect ${platformName}` after an earlier gate
  incorrectly searched only the `$platformName` interpolation form
- that allowed tests to pass while disconnected Android/iOS could still render
  `Connect Health Connect` / `Connect Apple HealthKit`
- the authoritative title expression is now platform identity only
- release contract explicitly rejects both `$platformName` and
  `${platformName}` Connect-prefixed forms
- `Connect`, `Disconnect`, and `Install Health Connect` remain action labels
  only
- permission-dialog action widths remain unchanged at the already-applied
  equal 124 logical-pixel widths pending physical verification

Health connection owner clean-state checkpoint:
- Apple HealthKit / Health Connect now shares the same `titleLarge + bold`
  sibling-section hierarchy as Data Coverage and Biometric Monitoring
- removal of redundant automatic connection success/disconnect feedback left
  `adaptive_messages.dart` and `platformShort` unreachable
- both dead references are removed
- normal platform title, Connect / Disconnect actions, widened permission-dialog
  actions, Q3 Stress presentation and real Sleep Duration remain preserved
- targeted Health connection/title contracts and analyzer must remain green
  before physical Android+iPhone closure

Health connection-title responsive hierarchy correction:
- physical iPhone verification showed `Apple HealthKit` wrapping to two lines
  after adopting the exact `titleLarge + bold` style used by the shorter
  `Data Coverage` and `Biometric Monitoring` labels
- the three sections remain sibling hierarchy, but identical typography was
  proven unsuitable for their unequal label lengths and available widths
- connection title now uses centralized `titleMedium + bold`
- no local font-size override or iOS-only font rule is introduced
- Data Coverage and Biometric Monitoring retain `titleLarge + bold`
- Android and iPhone physical verification must confirm Apple HealthKit and
  Health Connect remain single-line, readable and visually subordinate only by
  the amount required to preserve layout

Health systematic page/section header system:
- `Health Overview` remains the page-level Health heading and retains its
  existing `headlineSmall + bold` presentation
- all subordinate Health section headings converge on one semantic
  section-title tier using centralized `titleMedium + bold`
- Data Coverage, Biometric Monitoring, Health Insights, Symptom Tracker and
  Health Goals require leading semantic icons rather than plain-text headings
- Apple HealthKit / Health Connect retains its native connection icon while
  using the same section-title typography tier
- a reusable Health section-header owner is preferred over repeated Text/Icon
  implementations so typography, icon spacing, one-line behavior and trailing
  actions stay systematic
- Symptom Tracker must preserve its Add Symptom navigation action when moved
  to the centralized header
- physical Android and iPhone verification is required for title fit, icon
  alignment and trailing-action spacing before closure

Health grouped-dashboard decomposition finding:
- source proves `_buildHealthDashboard()` currently owns one outer Container
  containing HealthKitConnectionCard, Data Coverage and Biometric Monitoring
- this violates the intended independent-section architecture
- target remains: connection, Data Coverage, Biometric Monitoring, Health
  Insights, Symptom Tracker and Health Goals each own an independent outer
  carrier
- Health Overview remains the page-level header
- each subordinate section uses the centralized Health section-title system
  with semantic leading icon
- Home architecture must be copied from its actual source owner rather than an
  assumed file path; previous audit stopped because the guessed Home path did
  not exist
- no new carrier abstraction may be introduced until existing shared/Home
  ownership is checked to avoid duplicate design infrastructure

Health complete independent-section visual system:
- Health Overview remains the sole page-level heading and retains its existing
  page-title typography
- Apple HealthKit / Health Connect, Data Coverage, Biometric Monitoring,
  Health Insights, Symptom Tracker and Health Goals are sibling Health sections
- all sibling section headings use one compact semantic typography tier that
  remains single-line on physical iPhone and Android
- Data Coverage, Biometric Monitoring, Health Insights, Symptom Tracker and
  Health Goals require semantic leading icons; the connection section retains
  its native platform-health icon
- every sibling section must own an independent outer carrier rather than share
  the current long dashboard container
- current source proves `_buildHealthDashboard()` incorrectly groups
  HealthKitConnectionCard + Data Coverage + Biometric Monitoring
- Biometric Monitoring owns only its biometric grid
- Data Coverage owns only its coverage state
- Health Insights owns only its insight placeholder/real-content surface
- Symptom Tracker owns its symptom content and preserved Add Symptom action
- Health Goals owns its existing placeholder surface
- carrier geometry, borders, surface color and spacing must reuse the proven
  Home/shared visual architecture rather than introduce another competing style
- section-header and carrier architecture must be centralized where source
  evidence supports a shared owner
- physical Android and iPhone verification is mandatory after decomposition,
  including dark/light appearance, one-line headings, icon alignment, Q3 badge,
  safe-area clearance and connection-dialog presentation

AppSectionCarrier authority verification checkpoint:
- `lib/core/ui/app_section_carrier.dart` exists and declares itself as a shared
  outer carrier for major Flow Ai sections
- initial caller audit produced no caller output and terminated early because
  `rg` returned the normal no-match status under `set -e`
- existence alone therefore does not prove Home currently uses this carrier
- carrier git ownership, actual caller count and real Home outer-section
  implementation must be established before adopting or changing it
- its built-in header currently uses `titleLarge + bold`, while the Health
  physical-layout requirement targets compact one-line `titleMedium + bold`
- Health Overview remains untouched at page-heading level
- Health subordinate sections still require independent carriers, semantic
  icons and uniform one-line section-title treatment

Symptom Tracker haptic compile correction:
- restored Add Symptom behavior includes the existing light haptic feedback and
  navigation to EnhancedDailyFeelingsTracker
- source used `HapticFeedback.lightImpact()` without importing
  `package:flutter/services.dart`
- required Flutter services import is restored
- symptom action truth contract remains green
- symptom chips remain on centralized compact rounded-rectangle geometry
- analyzer must be zero before physical Android+iPhone verification

## M7-M9

Status: `UNRESOLVED`

Recover exact scope from canonical repository/history evidence before restating.

Do not invent mission names, percentages, requirements, or completion states.

## M10

Status: `UNRESOLVED`

Exact scope must be recovered before being restated.

# Release Execution Order

The authoritative execution order is the `IMMEDIATE RELEASE PLAN - ACTIVE`
at the top of this ledger.

Current grouped order:
1. complete remaining M6 physical Wellness verification
2. complete M3 mandatory monetization production gates
3. complete Identity / Lifecycle reconciliation
4. complete Cycle / Prediction reconciliation
5. complete analyzer/account-isolation/reachable synthetic-data integrity sweep
6. complete Android + iPhone physical release verification
7. run final analyzer/tests/build gates
8. controlled staging review, commit, push, fetch, and progress recalculation

Deferred/future missions do not override this order.

# Proven M6-C3 Findings

## Health

- authorization must not be represented as health-data availability
- health-data availability must not be represented as a health rating
- provenance must be preserved
- sleep duration uses real observation intervals
- synthetic active Health values previously identified were removed in C3
- physical Health Connect and HealthKit truth remain release gates

## Prediction

- insufficient cycle history must not create population-average production predictions
- central predictions are nullable
- Home now uses central prediction state
- legacy `PeriodPredictionEngine` remains under audit
- `/predictions` navigation is implemented and contract-verified; physical verification remains
- unsupported legacy prediction fields must not be recreated from assumptions

## Analytics

- empty analytics must not be represented as `Stable`
- unavailable trends stay explicitly unavailable
- analytics caches must be account-scoped
- synthetic active analytics discovered under M6 remain owned by M6

## Daily Feelings

- pure chevron back control
- theme-driven light/dark behavior
- geometry preserved unless a separate proven blocker requires change

# Release Contracts and Automated Evidence

Known C3 contract files include:

- `test/release_contracts/mission6_account_scoped_analytics_cache_contract_test.dart`
- `test/release_contracts/mission6_daily_feelings_back_chevron_contract_test.dart`
- `test/release_contracts/mission6_empty_health_trend_truth_contract_test.dart`
- `test/release_contracts/mission6_health_ui_compaction_contract_test.dart`
- `test/release_contracts/mission6_home_prediction_truth_contract_test.dart`
- `test/release_contracts/mission6_active_analytics_truth_contract_test.dart`
- `test/release_contracts/mission6_home_health_data_truth_contract_test.dart`

Known release-contract count reached `39/39` before later Health Connect and prediction-route audits reopened release blockers.

Automated contracts do not replace physical-device verification.

# Current Git State Rules

Expected HEAD during M6-C3:
`0b72cd92923f0124601302309612df5729564bdb`

Do not stage until P0 blockers and final reconciliation are complete.

Mixed `MM` and `AM` states must be reconciled intentionally.

Never use `git add -A`.

# Explicitly Excluded Untracked Files

Do not stage these as part of M6-C3:

1. `0x7b81ac44de1172a`
2. `0x8f45bf6d3d6ed488`
3. `ios/Podfile.backup.20260806141326`
4. `ios/Podfile.backup.20260806141926`
5. `ios/Runner.xcodeproj/project.pbxproj.backup.20260806144333`
6. `ios/Runner.xcodeproj/project.pbxproj.backup.20260806144938`

Do not delete them without a separate proven cleanup decision.

# Physical Release-Test Devices

## Android

- ID: `RF8NA1QJR7H`
- model: `SM_N770F`
- Android release: `13`

Additional facts require current ADB evidence.

## iPhone

- ID: `00008101-00050C191E44001E`
- relevant verification uses release mode

# Deferred and Future Release Ledger

These may not interrupt the current P0 queue unless proven release-blocking:

1. further Health Connect modal visual polish beyond current compaction
2. broader Health screen visual/text-density redesign
3. Home zero-health-data icon improvement
4. startup performance/skipped-frame optimization
5. broader dormant analytics/mock sweep
6. repository modernization and dependency/security cleanup at the proper RC/security gate
7. Firebase CocoaPods deprecation follow-up
8. audit `Real-time Biometric Analysis` wording if still active
9. Symptom Tracker low-contrast suggested-chip review if physical verification proves a major visibility issue
10. additional wearable integrations after Health Connect/HealthKit truth is release-safe
11. archived roadmap ideas remain historical candidates, not automatic current missions

# Archived Historical References

Reference-only:
- `docs/archive/MISSION_PLAN.md`
- `docs/archive/MISSIONS_PENDING.md`
- `docs/archive/FEATURE_ROADMAP.md`
- `docs/archive/DEVELOPMENT_STATUS.md`
- `docs/archive/DEPLOYMENT_STATUS.md`

Old branch rules, priorities, dates, and completion claims in archived documents do not override current repository evidence.

# Historical Evidence Preserved

- Google Sign-in error: `Apps with uid ... cannot masquerade as package com.flowai.app`
- prior Google sign-in error: `ApiException: 10 (DEVELOPER_ERROR)`
- historical deep-link error: `GoException: no routes for location flowai://invite/TEST123`
- canonical invite path historically recorded as `/invite/:code`
- pending invite key historically recorded as `pendingInviteCode`
- M1 historical record states Android deep links worked on warm/cold start and invite autofill was implemented

These are historical records unless reverified against current runtime.

# Current Release Definition of Done

Release is not ready until:

1. every current P0 is complete or explicitly proven nonblocking
2. no active synthetic/misleading health or prediction path remains
3. Android Health Connect behavior is truthful
4. iOS HealthKit behavior is truthful
5. prediction navigation has a valid truthful destination
6. account-deletion regression is classified
7. release contracts pass
8. analyzer passes
9. Android build passes
10. iOS release build passes
11. physical Android verification passes
12. physical iPhone release verification passes
13. release files are intentionally staged
14. final staged diff passes review
15. commit is pushed
16. fetch proves local HEAD equals remote branch HEAD
17. frozen percentages are recalculated from evidence

# Next Immediate Action

Continue `P0.1 Android Health Connect Availability`.

Do not begin deferred work until the current release queue permits it.

### M6 Health section hierarchy — shared icon polish
- Physical comparison showed Health section titles were already sufficiently strong, while the shared leading icons remained visually light.
- Verified authoritative owner: `lib/features/health/widgets/health_section_header.dart`.
- Verified before values: icon `22 px`, title gap `10 px`, `titleLarge + FontWeight.bold`, responsive `Wrap(spacing: 12, runSpacing: 8)`.
- Decision: preserve Health's compact identity rather than duplicate Home's icon carrier/subtitle hierarchy.
- Production change: shared section icon `22 px -> 24 px` only.
- Preserved: title typography, 10 px icon/title gap, responsive trailing-action behavior, cards, gradients, metric typography, HealthKit/Health Connect hierarchy, and truth semantics.
- No section subtitle/description lines added.
- Physical Android + iPhone verification remains required before closure.

### M6 Health section hierarchy — Android physical verification
- Physical device: Samsung SM-N770F, Android 13 / API 33.
- Current-worktree debug APK built, installed and launched successfully.
- Shared Health section icon size physically verified at the implemented 24 px hierarchy.
- `Data Coverage`, `Biometric Monitoring`, `Health Insights`, `Symptom Tracker`, and `Health Goals` present a consistent section-heading hierarchy.
- `Symptom Tracker` renders in full with no ellipsis.
- `+ Add Symptom` responsively moves below the title on the narrow Android layout instead of competing for title width.
- Metric-card geometry, dark-theme presentation, navigation, and health-data truth semantics remained intact in the observed screen.
- Android visual gate for the Health section-header mission: PASS.
- iPhone physical verification remains required before this UI mission closes.

### M6 Health section hierarchy — iPhone physical verification
- Physical iPhone verification completed on the current worktree.
- `Data Coverage`, `Biometric Monitoring`, `Health Insights`, `Symptom Tracker`, and `Health Goals` retain the centralized section hierarchy.
- Shared 24 px leading icons are visually balanced.
- `Symptom Tracker` renders fully with no ellipsis.
- `+ Add Symptom` responsively occupies its own line without competing with the title.
- Existing metric cards, dark presentation, bottom navigation, and HealthKit connection-card hierarchy remained intact.
- Android and iPhone visual gates for the Health section-header mission: PASS.
- No further section-heading UI mutation is justified.

### P0.3 iOS HealthKit — physical authorization/read verification
- Physical iPhone verification completed on the current worktree.
- HealthKit entitlement and `NSHealthShareUsageDescription` were present.
- Physical connection UI showed `Apple HealthKit` with `Access granted`.
- Runtime evidence recorded `Health data sync completed`.
- Runtime evidence recorded `Advanced Biometric Integration initialized with HealthKit`.
- Physical Health screen displayed an observed Heart Rate value of `84 BPM`.
- Temperature, Sleep Duration, and Stress Level remained `No data` where no observations were available.
- Data Coverage displayed `44% coverage`, consistent with partial supported metric availability.
- Authorization was not treated as equivalent to complete health-data availability.
- P0.3 iOS HealthKit authorization + real/partial/no-data read path: PASS.
- Separate privacy-copy audit remains open because `NSHealthUpdateUsageDescription` claims HealthKit write capability while no production HealthKit write API was found in the current repo-wide search.

### P0.4 Health-score semantics/reachability — release gate PASS
- `HealthProvider._calculateHealthScore()` remains dormant internal compatibility logic.
- Release reachability audit found no active production consumer of `HealthProvider.healthScore`.
- Active Home health presentation uses observed-data presence and snapshot `dataQuality`, not the dormant score.
- Active Health detail does not display the dormant score.
- Active analytics does not synthesize an unsupported overall health rating.
- Health-score reachability contract passed.
- Targeted analyzer passed.
- Dormant score code is retained because deletion is not justified without stronger ownership/reachability evidence.
- P0.4 release truth gate: PASS.

### P0.6 Account deletion — code/analyzer release gate PASS
- Active Account Management UI reaches `AuthService.deleteAccount()`.
- Cloud deletion is required before local account erasure proceeds.
- Backend callable confirms Firebase identity deletion with `identityDeleted: true`.
- Client rejects incomplete backend deletion confirmation.
- Targeted account-deletion / identity contracts passed: 15/15.
- Targeted analyzer for deletion gateway, auth service, and Account Management reported 0 issues.
- Controlled physical deletion using a disposable account remains required.
- Final account-isolation sweep remains required.

### M6 Production analytics account isolation
- Deep account-isolation audit proved `PerformanceAnalyticsDashboard` cache keys are user-prefixed and therefore account-scoped.
- `ProductionAnalyticsService` was active from app startup and could restore `_userId` from the global SharedPreferences key `user_id` when initialized without an authenticated user.
- That behavior could attribute later analytics events to a previous account after sign-out/account switch.
- Central fix removes implicit persisted-user restoration.
- Added explicit `setAuthenticatedUser(String?)` ownership that clears queued account-attributed events/session state whenever account scope changes.
- `clearAnalyticsData()` now also removes persisted analytics identity and clears in-memory identity/session state.
- Global analytics-enabled preference remains global by design; only account-attributed state is reset.
- Release contract added to prevent stale-account identity restoration regression.

### M6 Production analytics — central account-boundary binding
- Verified `ProductionAnalyticsService.setAuthenticatedUser()` previously had no external caller.
- `_storeUserData(...)` is the common successful-account persistence boundary across active authentication paths.
- `_clearAllUserData()` is the common account-scope teardown boundary used by sign-out/account deletion.
- Analytics account scope is now bound centrally from `_storeUserData(...)`.
- Analytics account scope is reset centrally from `_clearAllUserData()`.
- No provider-specific Email/Google/Apple duplication was introduced.
- Startup already-authenticated reconciliation remains a separate evidence-gated check.

### M6 Production analytics — startup account reconciliation
- Deep startup audit proved account lifecycle binding was complete for successful login, sign-out, and account deletion but missing for an account already authenticated when the app starts.
- `AuthService.initialize()` is the authoritative startup identity boundary because it initializes both Firebase authentication and `LocalUserService`.
- Added one `_syncAnalyticsAccountScope()` owner that resolves the active account through `getCurrentUser()` and binds `ProductionAnalyticsService` to that account UID.
- Normal Firebase-capable startup and local-only initialization fallback both reconcile analytics scope after AuthService becomes initialized.
- No Email/Google/Apple-specific startup logic was introduced.
- Together with `_storeUserData(...)` and `_clearAllUserData()`, analytics account attribution now covers startup, login/account change, sign-out, and account deletion.

### M6 Production analytics account isolation — code gate PASS
- Production analytics no longer restores a stale persisted account identity during initialization.
- AuthService startup reconciliation binds analytics to the currently resolved account.
- `_storeUserData(...)` centrally binds successful login/account changes.
- `_clearAllUserData()` centrally resets analytics scope for sign-out and deletion.
- Account-attributed queued events/session state are cleared across account-scope changes.
- Account-isolation contracts passed: 12/12.
- Auth/deletion/AppLock regression contracts passed: 11/11.
- Targeted analyzer passed with no issues.
- Code-side production analytics account-isolation gate: PASS.

### M6 Home greeting responsiveness — complete-name preservation
- Physical Android verification showed `Good evening, Leah!` renders fully.
- Physical iPhone verification proved identity persistence/reactivity by updating the account name to `Space`, but Home rendered `Good evening, S...`.
- Source audit proved the greeting itself forced `maxLines: 1` plus `TextOverflow.ellipsis`.
- This was classified as a presentation defect, not an Apple Sign-In, identity, SettingsProvider, or name-resolver defect.
- Central Home fix replaces greeting ellipsis with `FittedBox(fit: BoxFit.scaleDown)` while preserving `headlineSmall + bold`.
- The greeting remains single-line and preserves the complete authenticated first name.
- Android retains the existing typography when sufficient width is available; narrower layouts scale only when required.
- Date-row overflow behavior is unchanged.
- Physical Android + iPhone regression verification remains required.

### M6 Home main-section title density
- Physical iPhone evidence showed `AI Prediction Center` wrapping to two lines while other Home section headings were visually oversized for the available width.
- Theme audit proved `titleLarge` is 16 px and `titleMedium` is 14 px in both light and dark themes.
- A requested 20–30% blanket reduction would reduce headings to approximately 11–13 px and was rejected as unnecessarily aggressive.
- Main Home section titles now use the existing 14 px `titleMedium` typography step with bold weight.
- Scope is limited to Home section headings: Health Dashboard Matrix, AI Prediction Center, Health Insights Portal, Smart Action Command Center, Health Trends Visualization, and Premium Features.
- Home AppBar, metric/card titles, values, body copy, and navigation typography remain unchanged.
- Physical Android + iPhone verification remains required.

### M6 Code hygiene — zero-issue analyzer closure
- Release hygiene cleanup centralized deprecated API ownership instead of retaining per-widget legacy APIs.
- Color opacity calls migrated to `withValues(alpha:)`.
- Share actions migrated to `SharePlus.instance.share(ShareParams(...))`.
- Payment-method selection is centrally owned by `RadioGroup<PaymentMethod>`; child `Radio` widgets own only their values.
- Dropdown form initialization uses `initialValue`.
- QR color ownership uses `QrEyeStyle` and `QrDataModuleStyle`.
- Matrix transforms use non-deprecated Matrix4 APIs.
- Compiler-proven dead imports, locals, helpers, and fields were removed.
- Missing optional wellbeing observations remain missing rather than being converted into synthetic chart values.
- Full `flutter analyze lib` verified zero issues.
- Complete release-contract suite verified green.
- Existing staged set remained unchanged during cleanup.

### M6-H1 Symptom Tracker CTA centralization
- Symptom Tracker section title is owned only by `HealthSectionHeader`.
- `Add Symptom` was removed from the header trailing slot and moved into the section card as a full-width `OutlinedButton.icon`.
- Symptom navigation and haptic behavior are centralized in `_openSymptomTracker()`.
- The CTA continues to open `EnhancedDailyFeelingsTracker` with the current date.
- No duplicate symptom dialog or navigation owner was introduced.
- Code gate verified: centralized in-card CTA, Health contracts, full release contracts, and zero-issue analyzer are green. Physical Android + iPhone CTA verification remains required before M6-H1 closure.

### M6-H1 Symptom Tracker nested carrier decision
- Physical Health screenshot shows the in-card Add Symptom CTA and symptom chips are visually exposed directly on the outer Symptom Tracker section surface.
- Required hierarchy: outer Symptom Tracker section carrier -> section title -> inner content carrier -> Add Symptom action + symptom chips.
- The inner content carrier must reuse the same authoritative carrier/geometry system used by Health Insights where source ownership proves compatibility.
- Do not introduce a local one-off BoxDecoration solely for Symptom Tracker.
- Physical Android + iPhone verification remains required after implementation.

### M6-H2 Home and Health roadmap capsule convergence
- Physical Health screenshot proves Q3 2026 does not visually match Home roadmap/status capsules.
- Source audit proved Health uses AppUpcomingFeatureStatus while Home still contains a local duplicate status presentation.
- Required architecture: one authoritative shared roadmap/status capsule owner for Home and Health.
- Q3 2026, Q4 2026, NEW, Active, and Coming Soon semantics must remain distinct; centralization concerns presentation ownership, not falsifying availability.
- Do not patch Health to imitate Home locally. Converge both surfaces through the shared owner.
- Android + iPhone verification required after convergence.

### M6 physical review — Symptom carrier width and Q3 badge geometry
- Physical Health screenshots show the Symptom Tracker nested content carrier is horizontally over-inset compared with surrounding Health content surfaces, reducing usable width and making the CTA/chips feel compressed.
- Required correction: align the nested Symptom content surface with the established Health inner-content margins rather than adding local chip-width workarounds.
- Physical screenshots also show the Q3 2026 roadmap badge remains more oval/pill-like than the Home roadmap badges.
- Required correction: prove whether the discrepancy comes from the shared AppUpcomingFeatureStatus geometry or from different call-site constraints, then fix the authoritative owner only.
- Do not add local Q3 styling or Health-specific one-off padding.
- Reverify Android and iPhone after geometry convergence.

### M6 Health header contract exact-variable reconciliation
- Latest terminal evidence proved the stale Symptom Tracker header contract used the local variable `source`, not `health`.
- The previous shell guard therefore returned zero despite the stale assertion being present.
- The exact stale assertion `label: const Text('Add Symptom')` was replaced only in the affected contract.
- The contract now verifies the centralized production architecture: AppSectionActionButton + `label: 'Add Symptom'` + `_openSymptomTracker`.
- HealthSectionHeader remains the authoritative title owner and production Health UI was not rolled back.
- Guard design rule reinforced: inspect exact current variable names and source shape before mutation.

### M6 status parity exact assertion-shape reconciliation
- The shared AppUpcomingFeatureStatus production owner correctly uses `compact ? 6 : AppGeometry.radiusSm`.
- The Home/Health parity contract still asserted the previous unconditional `BorderRadius.circular(AppGeometry.radiusSm)` behavior.
- The previous repair guard correctly detected the stale token but its replacement block assumed a different multiline `contains(...)` layout and therefore performed no mutation.
- The contract was subsequently reconciled using a whitespace-tolerant semantic match against the exact `expect(shared, contains(...))` assertion.
- Compact roadmap/status badges remain centrally owned and use a 6 px rounded-rectangle radius; non-compact status retains AppGeometry.radiusSm.
- No Home-specific or Health-specific badge styling was introduced.

### M6-H2 Stress Level roadmap Q4 2026 decision
- Physical Android review confirmed the centralized compact roadmap badge shape is acceptable; do not alter its current geometry absent a regression.
- Stress Level roadmap copy was intentionally changed from `Q3 2026` to `Q4 2026`.
- AppUpcomingFeatureStatus remains the single presentation owner; only the roadmap value changed.
- Home/Health status geometry centralization remains intact.
- Existing contracts that directly encoded the previous Q3 Stress Level roadmap value were reconciled to Q4 without modifying unrelated status semantics.
- Android production build/install/launch had already passed before this copy-only roadmap change.

### M6-H2 Q4 roadmap Android gate verified
- Stress Level roadmap label is now `Q4 2026`.
- Compact roadmap/status geometry remains user-approved and centrally owned by AppUpcomingFeatureStatus.
- Health contract gate: 77 assertions passed.
- Zero-tolerance analyzer: no issues found.
- Complete release contract suite: 138 assertions passed.
- Physical Android debug build, install, and launch passed on the current worktree.
- Staged file set remained unchanged.
- Do not revisit roadmap capsule geometry unless a later physical regression is proven.

### M6-H1 Symptom Tracker squeezed-inner-carrier correction
- Physical Android review repeatedly showed the Symptom Tracker inner content surface was too horizontally compressed compared with the preceding Health/Biometric/Insights surfaces.
- This remained an OPEN M6-H1 item and must not be considered closed merely because contracts/analyzer were green.
- The outer Health section geometry remains unchanged.
- AppSectionContentCarrier remains the centralized inner-surface owner.
- Symptom Tracker reduces only its content horizontal inset from 14 px to 8 px while preserving 14 px vertical breathing room.
- No chip-width hacks, extra margins, duplicate carrier, or unrelated Health geometry changes were introduced.
- M6-H1 remains open until the refreshed Android screenshot proves visual alignment and the same result is verified on iPhone.

### M6-H1 exact outer-inset audit correction
- A previous alignment audit incorrectly matched screen call sites such as `_buildHealthInsightsSection(localizations)` rather than the actual widget function definitions.
- Exact function-definition audit subsequently proved Health Insights outer section padding = 18 px and Symptom Tracker outer section padding = 24 px.
- Symptom Tracker nested AppSectionContentCarrier was separately proven to remain at 8 px horizontal / 14 px vertical internal padding.
- The remaining physical misalignment therefore came from the Symptom outer section inset, not the nested carrier.
- Symptom Tracker outer padding was aligned from 24 px to the proven Health Insights reference value of 18 px.
- The alignment release contract was rewritten to locate exact widget function definitions rather than ambiguous call-site substrings.
- No inner-carrier reduction, chip-width workaround, negative margin, or duplicate component was introduced.
- Physical Android verification remains required before M6-H1 closure.

### M6-H1 Add Symptom CTA symmetric inset
- Source audit proved the corrected Symptom Tracker nested carrier uses 8 px horizontal and 14 px vertical internal padding.
- Physical review requested the Add Symptom CTA side gaps to equal its top gap rather than spanning nearly the full inner-carrier width.
- Required CTA contextual horizontal inset is mathematically derived as 14 - 8 = 6 px.
- The shared AppSectionActionButton continues to own button visuals and dimensions; Symptom Tracker owns only the contextual 6 px wrapper because the spacing relationship is specific to this section composition.
- Effective Add Symptom button left/right gap = 8 + 6 = 14 px, matching the 14 px top gap.
- Symptom chips retain the full 8 px inner-carrier horizontal inset and are not squeezed further.
- No shared carrier geometry or unrelated AppSectionActionButton callers were altered.
- Physical Android/iPhone verification remains required before M6-H1 closure.

### M6 Android physical UI pass — Health geometry convergence
- Physical Android screenshots verified the current Health worktree after the latest geometry changes.
- Symptom Tracker outer section alignment now visually matches the surrounding Health section hierarchy significantly better.
- Symptom Tracker nested content carrier no longer appears excessively squeezed.
- Add Symptom CTA side spacing visually balances its top spacing and no longer appears unnecessarily stretched.
- Symptom chips retain useful horizontal breathing room.
- Stress Level roadmap badge is user-approved in its current compact rounded-rectangle geometry and now displays `Q4 2026`.
- Health Connect Disconnect CTA appears visually proportionate and consistent with the intended Connect/Disconnect shared geometry.
- Do not continue cosmetic Android changes to these verified items absent a proven regression.
- iPhone physical verification remains required before M6-H1/H2 closure.

### M6-H1/H2/H4 Android + iPhone physical visual closure
- Physical Android and physical iPhone visual review both passed for the current Health UI.
- Symptom Tracker outer alignment is accepted on both platforms.
- Symptom Tracker nested content carrier is accepted on both platforms and no longer appears excessively squeezed.
- Add Symptom CTA top/side spacing and width are accepted on both platforms.
- Symptom chips retain useful content width and are accepted on both platforms.
- Stress Level roadmap badge geometry is accepted and displays `Q4 2026`.
- Connect/Disconnect shared CTA geometry is accepted on both platforms.
- Physical iPhone target: `00008101-00050C191E44001E`.
- Xcode sees the physical iPhone and the Runner target uses development team `9FY62NTL53`.
- Runner project and built Runner.app bundle ownership are verified as `com.flowai.health`.
- An earlier audit printed `PROJECT_BUNDLE_ID=NO` because a first-match awk parser selected the wrong build-settings occurrence; this was an audit-script defect, not proven bundle drift.
- Do not reopen these visual items without a new physical regression.

### M6 iOS Health write reachability classification
- The first write audit correctly stopped because `biometric_integration_service.dart` contains custom write bridge definitions, while the broad Dart regex also produced unrelated false positives.
- Follow-up classification separates write-method definitions from real production callers, custom platform-channel invocations from native iOS receivers, and dependency write capability from actual Flow Ai use.
- NSHealthUpdateUsageDescription may be removed only when production proves zero custom write callers, zero native iOS write handlers, and zero direct health-package WRITE/READ_WRITE or write API use.
- Dependency support for writing does not by itself establish application write reachability.
- No privacy disclosure is removed while reachability remains ambiguous.

### P0 M6 biometric service parser repair verified
- Unsafe regex deletion of five dormant Health write methods had corrupted `biometric_integration_service.dart` by stopping at nested method-body braces.
- Exact source audit proved the first damaged interval lies between complete `getActivityData()` and `_parseHealthData()`, and the second lies between complete `getDeviceCapabilities()` and `getPatternAnalysis()`.
- HEAD and index copies of the service were identical.
- Only those two damaged intervals were restored from the Git index using exact intact surrounding anchors.
- The whole file and worktree were not reset.
- Parser integrity, targeted service analysis, full zero-issue analyzer, Health contracts, and full release contracts must all remain green after repair.
- The five custom write methods remain restored but dormant: exactly one definition each and zero production callers.
- Do not attempt another dead-method deletion until a structurally safe Dart-aware strategy is selected.

### M6 read-vs-write capability truth
- Health authorization currently requests `HealthDataAccess.READ`.
- Five legacy custom write methods remain dormant with zero production callers.
- `getDeviceCapabilities()` previously used `_healthPermissionGranted` as fallback `canWriteData`, falsely allowing read authorization to imply write capability.
- The fallback is now fail-closed as `canWriteData: false`.
- `BiometricCapabilities.fromMap()` remains untouched pending exact producer/consumer and native ownership audit; it must not be changed based on assumption.
- Regression contract prevents READ authorization from being reused as write capability.

### M6 parallel biometric-stack deep audit
- Production `canWriteData` remains fully retired; the stale intermediate-state contract was reconciled to the final absence invariant rather than restoring obsolete production code.
- `BiometricIntegrationService` cannot currently be classified as dead solely from writer reachability because it has external Dart references from biometric UI, consumer-intelligence UI, and SmartNotificationService.
- Its private custom channel is `flowsense.health/integration`; native ownership must be proven independently from the Flutter `health` plugin.
- The service still carries legacy writeTypes and five dormant writer methods, all of which remain open cleanup items.
- `AdvancedBiometricService` and HealthProvider are audited in parallel to establish authoritative current Health ownership and prevent two competing health stacks.
- No legacy service deletion is permitted until route/service runtime reachability and native-channel ownership are resolved.
- Disconnect CTA light-mode semantic color remains open until reversible-action styling is compared against actual destructive actions and central theme tokens.
- All Prediction, Account Deletion, Privacy/Branding, Android+iPhone final pass, dormant-write cleanup, and final release/Git closure missions remain hanging until explicitly closed by evidence.

### M6 Disconnect geometry contract semantic reconciliation
- Production Disconnect uses the accepted theme-aware `errorContainer` / `onErrorContainer` tonal pair.
- Physical iPhone light-mode review passed: the revised Disconnect action is clearly distinguishable without the excessive destructive emphasis of solid error red.
- An older connection-action geometry contract still required `AppTheme.errorRed`, incorrectly coupling shared geometry parity to obsolete color semantics.
- The contract was reconciled to its actual responsibility: Connect and Disconnect share one geometry helper while retaining state-specific semantic colors/icons/callbacks.
- Production was not reverted to solid error red.
- Android light/dark and iPhone dark-mode physical Disconnect verification remain OPEN.
- Add Symptom versus symptom-chip visual hierarchy is now an active UI audit; no color mutation occurs until shared action and chip ownership are proven.
- Legacy BiometricIntegrationService consolidation/retirement remains ACTIVE.

### M6 Add Symptom primary-action hierarchy
- Deep UI ownership audit proved `AppSectionActionButton` has one real production call site: Health `Add Symptom`; the component's own constructor reference was previously counted as a second caller.
- Add Symptom already owns Flow Ai `primaryRose`, while symptom chips use neutral Material `surfaceContainerHighest` / `onSurfaceVariant`.
- The previous action styling used only a 14% rose surface with rose foreground, producing insufficient visual separation from the neutral symptom chips.
- The centralized action owner now renders its accent as a true filled primary action.
- Bright `primaryRose` does not use white text; it uses existing `AppTheme.onBrightAccent` for stronger readable contrast.
- Symptom chips remain unchanged, neutral, and secondary.
- Existing CTA geometry, 14 px contextual spacing, action navigation, icon, and section/carrier geometry remain unchanged.
- Android+iPhone light/dark physical verification of the revised Add Symptom action remains OPEN.
- Disconnect remaining Android/dark physical checks remain OPEN.
- BiometricIntegrationService consolidation/retirement remains ACTIVE.

### M6 legacy consumer runtime + synthetic-metric audit
- `BiometricIntegrationService` remains referenced by BiometricDashboardScreen, ConsumerIntelligenceDashboard, and SmartNotificationService, but its custom `flowsense.health/integration` native backend remains unproven.
- Current consumer method dependency is limited to initialize/isInitialized/hasHealthPermission/getBiometricAnalysis/refreshCache.
- Runtime reachability must be classified per consumer before migration or deletion.
- ConsumerIntelligenceDashboard contains fixed health-like metric assignments including overall health score, cycle regularity, stress, sleep quality, completeness, and improving-trend values; these are a truth-risk if the screen is reachable.
- Reachable synthetic health metrics are P0 and must be removed or replaced by authoritative real/unavailable state.
- Unreachable legacy screens should not be migrated merely to preserve obsolete architecture; reachability should drive retirement versus migration.
- AdvancedBiometricService/HealthProvider remain the authoritative current HealthKit/Health Connect ownership candidates.

### M6 authoritative Health stack consolidation complete
- Deep HEAD/index/worktree audit proved mission5_no_synthetic_health_fallbacks_test.dart contained legitimate distinct staged and unstaged states; the existing Git index was preserved byte-for-byte.
- C1 synthetic-health and C3 write-capability contracts were already migrated in the worktree and were not rewritten again.
- The remaining stale Mission 5 real-cycle contract was migrated from dead SmartNotificationService behavior to the live real_time_health_dashboard + AnalyticsService persisted-cycle-history ownership.
- BiometricDashboardScreen, ConsumerIntelligenceDashboard, SmartNotificationService, and BiometricIntegrationService had zero live external runtime reachability before retirement.
- The legacy custom `flowsense.health/integration` native backend remained absent.
- All four unreachable legacy owners were retired from the worktree.
- Known synthetic personal-health values contained in the retired ConsumerIntelligenceDashboard are no longer present in production.
- HealthProvider + AdvancedBiometricService remain the single authoritative HealthKit / Health Connect stack.
- Historical invariant contracts, analyzer, Health contracts, full release contracts, Android debug build, iOS no-codesign debug build, diff checks, and exact Git-index identity passed after retirement.
- Add Symptom Android+iPhone light/dark physical verification remains OPEN.
- Disconnect Android/dark physical verification remains OPEN.
- Prediction physical Android+iPhone verification remains OPEN.
- Account Deletion disposable-account physical verification remains OPEN.
- M6 Privacy & Branding Truth remains OPEN.
- Full two-device release pass and final Git closure remain OPEN.

### M6 reversible Disconnect semantic contract reconciliation complete
- Android dark-mode physical evidence proved Material errorContainer remained too visually destructive for reversible Disconnect.
- Flow Ai now centrally owns dedicated reversible-caution light/dark Disconnect tokens instead of changing global Material error semantics.
- The production Health connection card was migrated successfully to those tokens.
- An older geometry-parity contract initially remained coupled to errorContainer semantics and correctly blocked the gate.
- That stale semantic assertion was reconciled while preserving the contract's actual responsibility: shared Connect/Disconnect geometry with different state semantics.
- Light and dark Disconnect foreground/background pairs are contractually required to maintain at least 4.5:1 contrast.
- Analyzer, targeted Disconnect contracts, Health contracts, full release contracts, legacy-stack absence, diff checks, and exact Git-index identity must remain green.
- Physical Android+iPhone light/dark verification of the final Disconnect colors remains OPEN.
- Add Symptom Android dark-mode hierarchy is physically PASS; remaining device/theme states remain OPEN until explicitly reviewed.

### M6 cross-platform Health visual parity follow-up
- Android physical evidence did not visually reflect the first reversible Disconnect token change, so Disconnect remains physically OPEN despite green source/contracts.
- Deep ownership audit requires Android and iOS Health visuals to use the same shared Flutter connection-card source with no platform-specific color override.
- Because central/static theme values changed, running device sessions require hot restart rather than relying only on hot reload before final visual judgment.
- Add Symptom was physically judged slightly too bright; its action color was softened approximately 12% through a dedicated centralized symptomActionRose token rather than changing global primaryRose.
- Symptom chips remain neutral and unchanged.
- Add Symptom and Disconnect require Android+iPhone light/dark physical verification after hot restart.

### M6 cross-platform visual ownership audit corrected
- The first Add Symptom contrast audit stopped because `onBrightAccent` is an alias to `darkSurface`, while the audit parser only understood literal Color declarations.
- Alias-aware contrast verification replaced the shallow parser.
- The first Android/iOS parity gate also falsely treated any `Platform.isAndroid` / `Platform.isIOS` reference in HealthKitConnectionCard as a visual override.
- Deep scoped verification now checks only the Disconnect action call for platform-specific color branches; platform checks used for supported-platform capability and HealthKit/Health Connect wording are legitimate.
- Add Symptom remains on dedicated `symptomActionRose` (#E05E8A), approximately 12% softer than global primaryRose, while preserving the shared `onBrightAccent` foreground.
- Global primaryRose and neutral symptom-chip semantics remain unchanged.
- Disconnect light/dark caution tokens remain shared Flutter semantics with no Android/iOS-specific color branch.
- Physical Android+iPhone light/dark verification remains required after hot restart before visual closure.

### M6 Privacy Truth onboarding cleanup
- Deep data-flow audit proved all seven onboarding privacy switches lacked authoritative production ownership.
- `shareDataForResearch` and `enableAIInsights` were persisted preferences but did not govern a real research pipeline or the online AI request path.
- Decorative Health access, analytics, cloud backup, research, partner-sharing, marketing, and AI-consent switches were removed from onboarding.
- Dead onboarding consent model/controller/preferences plumbing was retired.
- Online AI disclosure now states that messages and the account identifier are sent over HTTPS to the configured AI service when the feature is used.
- Unsupported device-only AI wording, secure-cloud-backup wording, research-sharing claims, End-to-End Encryption, Military-grade security, and HIPAA-compliance marketing were removed from onboarding.
- Current backup status is disclosed as local-only.
- Health access is disclosed as user-approved read access and remains managed by the authoritative Health screen / platform settings.
- Android display name was corrected from `flow_ai` to canonical user-facing `Flow Ai`; iOS already used `Flow Ai`.
- Android and iOS builds, analyzer, privacy truth contract, full release contracts, diff checks, and exact Git-index identity must remain green.
- Privacy policy/store URLs and deployment metadata remain a separate evidence audit before final release; no URL is assumed correct merely because it exists in source.

### M6 full Health release-truth gate
- Entire reachable Health section must be audited before M6 closure: every screen, widget, provider, service, persistence path, analytics/insight path, native integration, route, contract, and physical Android+iPhone state.
- No fake, dummy, demo, sample, placeholder, synthetic, guessed, fallback, or misleading personal-health value/status is allowed in reachable production behavior.
- Missing observations must fail closed to truthful unavailable/no-data states rather than invented defaults.
- Every displayed device/source/freshness statement must be backed by actual provenance.
- Authorization must not be represented as available health observations or a connected wearable.
- Current Privacy/Branding release audit also found unverified store metadata including clinical-grade reporting, end-to-end encryption, Medical categorization, and Flow iQ URLs; these remain open until exact ownership/reachability and URL evidence are classified.
- M6 cannot close until the full Health truth gate and Privacy/Branding release-metadata gate are green plus physical Android+iPhone validation is complete.

### M6 full reachable Health truth audit active
- M6 Health remains active until every reachable Health and health-adjacent production path is proven truthful.
- Zero tolerance applies to fake, dummy, demo, sample, placeholder, synthetic, guessed, default-as-observation, simulated, and misleading health values/statuses.
- Audit scope includes Health screens/widgets, AdvancedBiometricService, HealthProvider, feelings/mood tracking, symptoms, analytics/insights, AI health paths, prediction-adjacent health behavior, platform HealthKit/Health Connect configuration, persistence, provenance/freshness, routes, contracts, and physical Android+iPhone rendering.
- Health-adjacent legacy/clinical/analytics/deployment code must be classified by actual runtime reachability before migration or retirement.
- Deployment metadata currently contains unverified clinical-grade, end-to-end encryption, Medical-category, Flow iQ URL, and simulated-build content; none may be treated as release truth until reachability/ownership is proven.
- Physical Disconnect/Add Symptom Android+iPhone light/dark verification remains open independently of code-contract gates.
- M6 Privacy/Branding release metadata remains open.
- Prediction remains next in mission order only after M6 Health/Privacy closure.

### M6-H13 Health input truth and AI fail-closed complete
- Unrecorded wellbeing/mood/energy inputs no longer receive an implicit 5/10 midpoint.
- Null/unrecorded state remains explicit until the user selects a real value.
- Slider numeric values are only dereferenced after the recorded-value branch is proven non-null.
- Production-reachable EnhancedAIChatService now fails closed for health-related requests when the online AI service is unavailable rather than generating local health guidance.
- Non-health FAQ/app-help fallback remains available.
- Analyzer, targeted Health truth contract, complete Health contract set, full release contract suite, diff checks, and exact staged-index identity passed.
- Remaining M6 closure gate is physical Android+iPhone Health verification, including Disconnect, Add Symptom, unrecorded feelings, truthful No-data/observed-data states, and light/dark parity.

### M6-H14 truthful unrecorded Health input runtime safety
- Post-contract source inspection found a runtime null-assertion risk that static analysis could not detect: an unrecorded nullable health input was still passed to Slider through `sliderValue!`.
- Unrecorded wellbeing, mood, and energy inputs now render a truthful 1–10 direct-choice control with nothing preselected.
- No implicit midpoint/default personal-health observation exists.
- After the first real user selection, the normal slider becomes available for adjustment.
- AI health failure remains fail-closed.
- Analyzer, targeted Health truth tests, complete Health contracts, full release contracts, diff checks, and exact staged-index preservation must remain green.
- Physical Android+iPhone Health validation remains the final M6 closure gate.

### M6-H15C final Health copy truth complete
- Final Daily Feelings unrecorded guidance now uses `Tap a number to record` at all three relevant Health input sites.
- `Tap or drag to record` is fully removed because dragging is unavailable before the first real value exists.
- Health Data Coverage count is sourced from `snapshot.metricProvenance.length` and is now labeled `observed metric type(s)`.
- Coverage percentage is explicitly labeled `availability coverage`; it is not represented as clinical quality, completeness, or synchronization percentage.
- Stale `synced metric` and `availability only` wording was removed.
- The previously stale `mission6_active_analytics_truth_contract_test.dart` was reconciled to the stronger source semantics.
- Reconciled targeted contracts: 12 PASS.
- Complete Health release contracts: 137 PASS.
- Full release contract suite: 168 PASS.
- Flutter analyzer: zero issues.
- Exact staged Git index remained byte-for-byte unchanged:
  - tree `96e9a3f6859154f530df3096923a8d4a2227af86`
  - staged binary SHA256 `de8fb3413bb735541542c93ddfb1f590a2f0eb926522764f39ad68f861f757ba`
- Health code-truth gate is green.
- Remaining M6 closure gate is physical Android light/dark runtime verification.
- iPhone light/dark Health verification already passed previously, subject to confirming the latest copy after hot restart.
- Monetization remains the immediately next active mission after M6 Health physical closure.

### M6-H16 Android physical Health closure
- Health source, analyzer, Health contracts, full release contracts, and iPhone physical verification are already green.
- Android physical runtime verification is the final Health closure gate.
- Required Android evidence: light/dark Health screen, Connect/Disconnect styling, Health Insights, Data Coverage wording, Add Symptom hierarchy, unrecorded Daily Feelings, first-value selection, and persistence after navigation/reopen.
- Unrecorded Daily Feelings must show `Not recorded` and `Tap a number to record`, with no numeric value preselected.
- Data Coverage must use observed metric count from provenance and label the percentage `availability coverage`.
- Missing health observations must remain `No data`; they must never render fabricated zero/default observations.
- If Android passes, M6 Health closes/freeze and Monetization becomes the immediately active mission.

### M6 Health / Wellness release gate closed
- Health code-truth gate is green.
- Flutter analyzer is clean.
- Final Health truth, Disconnect semantics, connection-action parity, symptom hierarchy, unrecorded-input truth, AI health fail-closed, provenance/coverage semantics, and Health write-absence contracts are green.
- No implicit 5/10 Daily Feelings observation remains.
- Missing Health observations fail closed to truthful No data / unavailable states.
- Health Data Coverage separates observed metric count from availability coverage.
- Disconnect uses reversible caution semantics.
- Add Symptom uses the softened dedicated symptom action rose and remains visually distinct from neutral symptom chips.
- iPhone light/dark Health physical verification passed.
- Android light/dark Health visual/runtime parity was confirmed by the user as matching the accepted iOS implementation.
- Android and iOS share the authoritative Flutter Health UI owners; platform differences remain limited to legitimate HealthKit / Health Connect capability behavior.
- Legacy synthetic Health architecture remains retired.
- No Health write capability is exposed.
- Daily Feelings persistence has a real persistence owner in code; a separate leave/reopen persistence smoke check may remain in final release validation if not independently physically observed.
- M6 Health is frozen. Do not reopen it without concrete regression evidence.
- Monetization is now the active mission.
- Current-release re-audit reconfirmed Add Symptom as ALREADY_CORRECT / CLOSED WITH EVIDENCE: centralized `AppSectionActionButton`, single `_openSymptomTracker` navigation owner, dedicated softened `symptomActionRose`, and previously accepted Android+iPhone visual parity; no Health mutation was justified.

- DEFERRED / FUTURE RELEASE — Add Symptom visual refinement:
  - keep the centralized `AppSectionActionButton` owner; do not create a Health-specific button implementation
  - explore a subtle Biometric Spectrum treatment derived from the existing Biometric Monitoring palette: rose → warm amber → soft blue → mint/teal
  - colors should blend/fade smoothly at low visual intensity rather than appear as a saturated rainbow
  - preserve strong text/icon contrast, light/dark theme integrity, and the existing softened CTA hierarchy
  - this is visual polish only and must not reopen the frozen current-release Health gate

### Monetization active — authoritative entitlement audit
- M6 Health is closed/frozen and Monetization is now active.
- Production Android and iOS AdMob application IDs and ad-unit IDs are present.
- No Google sample/test ad IDs were found in the initial audit.
- AdMob initialization is gated by UMP consent and `canRequestAds`.
- Subscription checkout, purchase stream, restore path, receipt validation, and backend-revalidated persisted entitlement paths exist.
- Before release, Monetization must prove one authoritative Premium entitlement owner across every feature gate.
- `FeatureGate` currently references `PremiumService` while the main purchase/runtime entitlement path uses `SubscriptionProvider`; this is under active split-brain audit.
- Premium marketing copy currently includes `Advanced health condition detection`; this must be reconciled with Health truth before release unless backed by a real production feature.
- Remaining release gates: receipt-validation configuration, identity binding/account switching, Apple/Google transaction semantics, expiry/refund/cancellation behavior, restore truth, premium ad suppression, UMP privacy options, store product catalog, and physical Android+iPhone checkout/restore verification.

### MON-M1 authoritative entitlement centralization
- Monetization audit found a release-blocking entitlement split-brain.
- Real store purchases, restore, backend receipt validation, persisted entitlement revalidation, and primary Premium UI are owned by SubscriptionService / SubscriptionProvider.
- PremiumProvider is an acceptable presentation proxy because it receives SubscriptionProvider through ChangeNotifierProxyProvider.
- Legacy PremiumService has store purchase and restore paths disabled and initializes with no active subscription.
- FeatureGate incorrectly read PremiumService, which could report Free after a valid backend-validated purchase and could therefore allow Premium users to be treated as ad-supported.
- FeatureGate was centralized on SubscriptionProvider.isPremium.
- `adsEnabled` and `canUploadImages` now inherit the same validated entitlement truth.
- PremiumService is classified LEGACY; retirement remains deferred until all residual callers are proven dead or migrated.
- A monetization-specific authoritative entitlement regression contract was added.

### MON-M2 receipt and restore truth audit active
- MON-M1 authoritative entitlement centralization is closed.
- MON-M2 audits authenticated receipt-validation identity binding, Apple transaction/original transaction identity, Google purchase-token/package binding, backend validation authority, persisted-entitlement revalidation, expiry/refund/revocation/cancellation handling, restore semantics, account-switch safety, and replay/idempotency protection.
- Premium must never be granted from local purchase history, stale preferences, or restore callbacks without authoritative validation.
- Any missing backend evidence is classified separately from client correctness; no client assumption is treated as server proof.
- MON-M2 remains active until receipt/restore truth is proven or blockers are corrected.

### MON-M2A.1 receipt backend verification rerun
- The previous live receipt-service verification stopped because `curl` was unavailable in the local shell.
- No source mutation occurred before that stop.
- Backend verification was rerun using Python standard-library HTTPS rather than adding an external dependency.
- Client receipt routing remains fail-closed and requires HTTPS, Firebase Bearer authentication, future expiration, transaction ID, and original transaction ID before Premium can be accepted.
- Apple, Google, and subscription-status Cloud Run routes must be proven reachable and protected before MON-M2 can close.
- Legacy local-account identity and Firebase monetization identity remain under exact source classification; identity validation will not be weakened to make purchases pass.
- Any fix must preserve authoritative server validation and account ownership.

### MON-M2B deep monetization identity audit
- Deployed Apple receipt, Google receipt, and subscription-status routes were previously proven live and authentication-protected; MON-M2B rechecks them rather than relying only on earlier evidence.
- A structural distinction exists between the primary app account identity and Firebase cloud identity for legacy local accounts.
- Local accounts can remain the primary app identity while an anonymous Firebase identity authorizes cloud services.
- Receipt ownership is intentionally bound to the authenticated Firebase ID-token identity.
- Receipt authentication must not be weakened, bypassed, or replaced with client-supplied ownership claims.
- MON-M2B audits the complete identity lifecycle before mutation: local UID creation, Firebase identity establishment/linking, paywall identity resolution, SubscriptionProvider lifecycle, account switching, sign-out/delete behavior, persisted entitlement ownership, purchase-stream ownership, restore, expiry/revocation/refund semantics, replay/idempotency, and every Premium state mutation.
- Any production fix must establish one deliberate monetization identity boundary and prevent entitlement leakage between accounts.
- No fake, mock, dummy, demo, local-only, or validation-bypass Premium grant is acceptable.

### MON-M2B backend and account-isolation deep audit
- Receipt backend source ownership is confirmed at `services/receipt-service/src/index.ts`; prior classification that backend source was absent was incorrect and is superseded.
- Deployed receipt endpoints remain separately proven live and authentication-protected: Apple, Google, and subscription-status = 3/3.
- Backend ownership, receipt verification, entitlement persistence, subscription-status authorization, expiry/revocation behavior, replay/idempotency, and backend test coverage were deeply audited.
- SubscriptionProvider is application-global and its current initialization guard is not user-scoped.
- A global `_isInitialized` guard without an initialized-user identity can preserve an earlier account's provider state across account changes; this is a release-blocking account-isolation risk if confirmed by the structural gate.
- SubscriptionService persisted entitlement itself checks `candidate.userId`, which is good, but that check cannot protect a provider that refuses to reinitialize for the new account.
- Legacy local app identity versus anonymous Firebase receipt identity remains a separate monetization identity-boundary issue.
- Neither issue may be solved by weakening Firebase receipt authentication, client-side Premium grants, local entitlement bypass, or dummy identity mapping.
- Next fix must centralize account-bound SubscriptionProvider lifecycle first, then resolve the local/Firebase monetization identity boundary against the actual account architecture.

### MON-M2C identity ownership and account lifecycle audit
- Deployed receipt API remains proven at three protected routes: Apple receipt, Google receipt, and subscription status.
- Client-side receipt validation remains fail-closed and Firebase-ID-token authenticated.
- Legacy-local app accounts and Firebase cloud identities are distinct identity domains unless explicitly linked.
- The active monetization blocker is not allowed to be solved by weakening Firebase authentication or accepting a client-supplied UID.
- MON-M2C audits local UID generation, Firebase cloud-identity lifecycle, account-linking ownership, paywall identity resolution, SubscriptionProvider initialization lifetime, sign-out/login/account switching, purchase callback ownership, entitlement persistence, backend UID ownership, and cross-user status lookup.
- SubscriptionProvider account-switch behavior is independently classified because provider-level stale entitlement can bypass otherwise-correct user-scoped persistence.
- Any resulting fix must create one deliberate authoritative monetization identity boundary and must clear/reload entitlement on account change.

### MON-M2D account isolation and stale-callback closure
- SubscriptionService is now bound to an explicit active user and identity generation.
- SubscriptionProvider is independently bound to an initialized user and initialization generation.
- Previous-account entitlement is cleared to Free before a new account is initialized.
- Previous purchase and entitlement listeners are cancelled/replaced at account boundaries.
- Stale purchase callbacks cannot validate or grant Premium after an account change.
- Restore completion is account/generation scoped.
- Backend subscription-status loads cannot overwrite a newer account after asynchronous completion.
- Subscription persistence is account/generation scoped.
- AI insight usage persistence is account scoped.
- Persisted subscription loading continues to reject `candidate.userId != userId`.
- Account-isolation release contract added and passed: 5 tests.
- Complete Monetization contract set passed: 25 tests.
- Receipt-service backend tests passed: 6/6.
- Full release contract suite passed: 176/176.
- Flutter analyzer passed with zero issues.
- Premium bypass/demo sweep passed.
- Exact staged Git tree and staged binary diff remained byte-for-byte unchanged.
- MON-M2D is closed.
- Separate legacy-local app account versus Firebase receipt identity remains active and unresolved.

### MON-M2F durable monetization identity closure
- Status: CLOSED.
- Receipt ownership requires a matching non-anonymous Firebase identity.
- Legacy-local and anonymous identities fail closed for purchase and restore.
- SubscriptionProvider delegates identity truth to SubscriptionService; paywall does not fabricate, replace, sign out, or directly manipulate Firebase identity.
- Verified regression: 31/31 monetization contract tests passed.
- Receipt backend: 6/6 tests passed.
- Full release contracts: 182/182 passed.
- Flutter analyzer: 0 issues.
- Premium bypass sweep: PASS.
- Staged Git index preserved exactly:
  - tree: 96e9a3f6859154f530df3096923a8d4a2227af86
  - staged binary SHA256: de8fb3413bb735541542c93ddfb1f590a2f0eb926522764f39ad68f861f757ba
- Monetization Gate 4/15 closed.

### MON-M3 Apple and Google lifecycle backend verified
- Status: backend lifecycle policy verified; Gate 5 remains OPEN pending mobile lifecycle enforcement.
- Apple:
  - ACTIVE allowed only with future verified transaction expiry.
  - REVOKED denied.
  - EXPIRED denied.
  - BILLING_RETRY denied.
  - BILLING_GRACE_PERIOD requires verified signed renewal data and future grace-period expiry.
- Google:
  - SUBSCRIPTION_STATE_ACTIVE allowed with future provider expiry.
  - SUBSCRIPTION_STATE_IN_GRACE_PERIOD allowed with future provider expiry.
  - SUBSCRIPTION_STATE_CANCELED preserved only as paid-through cancellation until provider expiry.
  - ON_HOLD, PAUSED, EXPIRED, PENDING and UNSPECIFIED have no entitlement branch.
- Backend build passed.
- Backend lifecycle test suite: 8/8 passed.
- Existing staged Git index preserved.
- Next required work: expose/persist lifecycleStatus and make mobile receipt validation + entitlement grant consume only supported lifecycle states.

### MON-M3 lifecycle entitlement closure
- Status: CLOSED after backend + mobile lifecycle enforcement and full regression.
- Apple lifecycle authority:
  - ACTIVE with future verified access can grant entitlement.
  - BILLING_GRACE_PERIOD requires verified signed renewal data and future grace expiry.
  - REVOKED, EXPIRED and BILLING_RETRY fail closed.
- Google lifecycle authority:
  - ACTIVE with future provider expiry can grant entitlement.
  - IN_GRACE_PERIOD with future provider expiry can grant entitlement.
  - CANCELED can grant only paid-through entitlement until the verified provider expiry.
  - Unsupported/non-entitled states fail closed.
- Backend returns and persists lifecycleStatus.
- Mobile parses lifecycleStatus into a closed typed enum.
- Missing/unknown lifecycle state fails closed.
- Mobile entitlement additionally requires valid backend response, future expiry and both transaction identifiers.
- SubscriptionService performs a defense-in-depth grantsActiveEntitlement check immediately before Premium mutation.
- No fabricated lifecycle state or local Premium bypass is permitted.

### MON-M4 production store resolution closure
- Status: CLOSED.
- Android:
  - flow_ai_premium_monthly opened real Google Play billing.
  - flow_ai_premium_yearly opened real Google Play billing.
- iPhone:
  - Premium screen resolved Monthly $12.99 and Yearly $99.99.
  - Monthly purchase action opened the Apple purchase/account sheet.
- Client/backend product IDs, Android package and iOS bundle were already proven aligned.
- ProductDetails originate from the platform stores, not fabricated locally.
- No purchase was intentionally completed during product-resolution verification.
- Gate 6/15 closed.

### MON-M5 Premium claim truth correction
- Status: Gate 7 release paywall correction verified; repo-wide legacy/secondary claim debt remains explicitly queued below.
- Kept: Unlimited AI Insights — production Premium entitlement/quota evidence supports it.
- Kept: Export Your Data — PDF or CSV — production implementations were proven.
- Kept with truthful wording: Advanced Analytics — Explore your health trends and tracked patterns.
- Removed from production paywall: Deep health condition detection & tracking.
  - Condition-detection implementation exists but no external production caller was proven.
- Removed from production paywall: Priority Support.
  - No differentiated Premium support path was proven.
- Removed from production paywall pending Gate 8: Ad-Free Experience.
  - Premium ad-free entitlement metadata exists, but complete runtime ad suppression is not yet proven.
- Permanent contract:
  test/release_contracts/monetization_premium_claim_truth_contract_test.dart

#### Hanging follow-ups preserved
- Gate 8 must audit every reachable AdMob/banner/interstitial/rewarded path and prove Premium suppression before Ad-Free can be marketed.
- Remaining Premium wording outside the main paywall must be classified and corrected where user-reachable:
  - upgrade_prompt_dialog.dart — Priority support
  - subscription.dart — priority support
  - feature_comparison_widget.dart — Priority Support
  - premium_feature.dart — Priority Support metadata
  - subscription_provider.dart — ad-free marketing copy
  - subscription_plan.dart — Priority support / Ad-free experience
  - subscription_service.dart — health condition detection / Ad-free experience / Priority support
  - premium_service.dart — Priority Support
- advanced_prediction_models.dart health-condition text is implementation/documentation evidence, not by itself a production marketing claim.
- Do not close these secondary claim items silently; resolve reachability/ownership during Gate 7 cleanup or the corresponding Gate 8 ads work.

### MON-M5.9C Secondary Premium claim cleanup
- Removed active health-condition-detection marketing from store product metadata.
- Removed active Ad-Free marketing pending Gate 8 proof.
- Removed active Priority Support marketing.
- Reachable UpgradePrompt messaging now advertises release-proven Premium capabilities only.
- Serialized `prioritySupport` compatibility key remains preserved.
- Runtime `prioritySupport` access fails closed.
- Removed prioritySupport from PremiumService feature catalog and Premium/Ultimate tier grants.
- Removed Priority Support and Ad-Free Experience from SubscriptionPlan metadata.
- Permanent Premium claim-truth contract extended.

#### Gate 7 still open
Remaining Premium truth debt must be classified before closure:
- AI/prediction accuracy percentages
- healthcare-provider integration
- medical-data sync
- appointment scheduling
- health-record integration
- Excel export
- biometric/wearable sync
- multi-user/family profiles
- predictive health modeling
- export to healthcare providers
- white-glove support
- lifetime data storage
- other medical/diagnostic marketing

Dormant FeatureComparisonWidget remains tracked and intentionally undeleted.

Gate 8 remains responsible for proving complete Premium ad suppression before Ad-Free marketing can return.

### MON-M5 Gate 7 Premium feature truth — CLOSED
- Gate 7/15 CLOSED only after authoritative current-state reconciliation.
- Production Premium value is women-centered and limited to release-proven capabilities:
  - Unlimited AI Insights.
  - Cycle & Wellness AI Insights.
  - Advanced Analytics for tracked trends and patterns.
  - PDF/CSV data export.
- Unsupported medical/product promises are absent from the whole Premium domain:
  - 95%+ prediction accuracy.
  - condition-detection marketing.
  - healthcare-provider / doctor integration.
  - direct wearable synchronization.
  - multi-user/family profiles.
  - predictive-health modeling promises.
  - export-to-healthcare-provider promises.
  - white-glove support.
  - lifetime data storage.
- Serialized legacy keys are intentionally preserved for compatibility:
  - healthcareIntegration
  - biometricSync
  - multiUserProfiles
  - prioritySupport
- All four unsupported legacy capabilities fail closed at runtime.
- No active PremiumService feature objects or tier grants remain for those capabilities.
- Apple Health / Health Connect remain truthful core health-data integrations and are not marketed as direct wearable or Premium-only functionality.
- Whole-Premium-domain release contract prevents unsupported women-health marketing from silently returning.

#### Next active monetization mission
- Gate 8: AdMob + Premium ad suppression.
- Ad-Free marketing remains prohibited until every reachable production ad path is proven to suppress ads for Premium.

### MON-M6.2 Central Premium ad-suppression ownership
- Gate 8 audit proved production Android/iOS AdMob app IDs and ad-unit IDs are present.
- Active runtime AdMob source contains no Google sample publisher IDs.
- UMP consent is centralized by AdConsentService and Mobile Ads initializes only after consent verification.
- Release blocker found:
  - AdMobService previously had no authoritative Premium entitlement gate.
  - startup could preload ads before a returning Premium account finished entitlement resolution.
  - SubscriptionProvider only disposed loaded ads reactively after some Premium entitlement events.
  - old disposal did not clear stored ad references/readiness flags.
  - in-flight loads could complete after entitlement changed to Premium.
- Architecture corrected at authoritative ownership:
  - SubscriptionProvider remains the validated entitlement owner.
  - AdMobService owns centralized ad-request/show enforcement.
  - ads default fail-closed until entitlement resolves.
  - account transitions immediately suppress ads.
  - initial backend-resolved entitlement and all subsequent entitlement events drive the same suppression policy.
  - unknown/error entitlement remains ad-suppressed.
  - Premium transition disposes and clears loaded interstitial/rewarded ads.
  - in-flight interstitial/rewarded callbacks reject loaded ads when entitlement/consent no longer permits advertising.
  - all load/show paths remain gated by canLoadAds, which now requires both UMP consent and non-Premium entitlement.
- Permanent release contract:
  test/release_contracts/monetization_ad_suppression_contract_test.dart

#### Gate 8 still open
- Verify no reachable banner owner bypasses centralized policy.
- Audit privacy-options UI reachability.
- Validate free vs Premium behavior physically on Android and iPhone.
- Verify account transition Premium -> Free and Free -> Premium behavior where safe.
- Do not restore Ad-Free marketing until physical two-device suppression proof is complete.

### MON-M6.3 Gate 8 banner/privacy reachability audit
- Static follow-up after centralized Premium ad suppression.
- Audit covers:
  - banner ownership and canLoadAds enforcement
  - every AdWidget/show caller
  - privacy-options implementation and user reachability
  - Free-account ad re-enable path
- Gate 8 remains open until Android + iPhone physical runtime verification proves:
  - Premium users receive no banner/interstitial/rewarded ads
  - Free users can receive ads only when UMP consent permits
  - Free -> Premium suppresses and clears ads immediately
  - Premium -> Free re-enables ads only after validated entitlement and consent allow it
  - privacy options remain reachable where legally required

### MON-X Premium capability enforcement — RELEASE BLOCKER
- Cross-cutting monetization requirement from product leadership.
- A capability marketed or presented as Premium must be genuinely inaccessible without validated Premium entitlement.
- Decorative Premium labels, dummy locks, informational-only gates, or alternate routes that bypass entitlement are prohibited.

#### Required audit
For every release-proven Premium capability:
- identify authoritative runtime owner.
- identify every route/screen/action that exposes it.
- verify entitlement before navigation or execution.
- verify deep links / alternate routes cannot bypass the gate.
- verify direct service/API calls cannot bypass UI gating.
- verify unknown entitlement fails closed.
- verify account switching immediately revokes stale Premium access.
- verify Premium -> Free transition revokes access without restart.
- verify Free -> Premium unlocks only after validated entitlement.
- verify offline/startup behavior does not trust stale local Premium state.
- add permanent release contract for every Premium capability category.
- physically verify representative locked/unlocked flows on Android and iPhone.

#### Current release-proven Premium capabilities to enforce
- Unlimited AI Insights.
- Cycle & Wellness AI Insights.
- Advanced Analytics / tracked trends and patterns where designated Premium.
- PDF/CSV Premium export capability where designated Premium.

#### Release policy
- No Premium capability is considered complete merely because it appears in paywall copy.
- Marketing truth and runtime access enforcement are separate proofs.
- This mission is release-blocking and must close before final monetization/release sign-off.

### FUTURE-UX Authentication experience redesign
- Future release mission; does not interrupt the current monetization release blockers.
- Current login/sign-up experience is considered too complex and visually under-refined.

#### Product direction
Design a simpler, beautiful and trustworthy authentication experience centered on women using Flow Ai.

Goals:
- minimal cognitive load.
- fewer screens and decisions.
- clear distinction between Sign in and Create account without clutter.
- elegant visual hierarchy and refined spacing/typography.
- warm, modern visual language without stereotypes or excessive decorative elements.
- privacy and intimate-health-data trust communicated clearly.
- no unnecessary medical or technical wording.
- strong accessibility and dark-mode parity.
- responsive Android/iPhone parity.
- fast keyboard/form behavior.
- clear password/error/recovery states.
- Apple/Google/native authentication only where production identity architecture supports it safely.
- preserve durable monetization identity requirements.
- preserve account-switch/delete/sign-out integrity.
- no demo identities or insecure shortcuts.

#### Research/design requirement before implementation
- audit current auth routes, screens, providers, Firebase/local identity ownership and account migration constraints.
- map the shortest safe authentication journey.
- prototype the new visual hierarchy before source mutation.
- validate physical Android + iPhone UX.
- add auth-flow release contracts so visual simplification cannot weaken identity integrity.

#### Women-centered design principles
- calm and reassuring rather than clinical or alarmist.
- privacy-first for menstrual, symptom and wellness data.
- concise supportive language.
- clear consent and account ownership.
- inclusive across different cycle patterns and life stages without assuming every user has the same needs.


#### AUTH10 — Onboarding Experience Redesign — FUTURE

Status:
- FUTURE RELEASE.
- Must not interrupt current Monetization / Premium release blockers.

Scope:
- Redesign and normalize the complete 6-page onboarding journey:
  1. Welcome to Flow Ai
  2. Powerful Features
  3. Your Privacy Matters
  4. Enable Notifications
  5. Setup Your Profile
  6. Reminder Preferences
- Rebalance vertical spacing, content density, hierarchy, cards, controls,
  bottom actions, safe-area handling, and short/tall viewport behavior.
- Preserve truthful privacy, notification, health, and account wording.
- Remove visually inconsistent or redundant onboarding treatments.
- Profile/reminder pages require dedicated responsive cleanup.
- Maintain dark/light theme parity.
- Require Android + iPhone physical verification before closure.

Navigation design contract:
- Directional navigation must use chevrons only.
- Forward: `>`
- Back: `<`
- Do not use `→`, `←`, `->`, `<-`, or arrow-with-stem icons in the
  redesigned onboarding/authentication experience.
- Example: `Next >`, never `Next →`.
- Centralize navigation affordance styling rather than fixing each page
  independently.

Implementation rule:
- Audit authoritative onboarding controller/screen ownership before mutation.
- Do not patch generated localization files directly.
- Any shared change must be made at the central owner and protected by tests,
  analyzer, and two-device physical evidence.

### MON-M6.7 Authoritative AdMob production ID inventory
- Android and iOS AdMob application IDs verified directly from canonical release source.
- Banner, interstitial and rewarded production ad-unit IDs verified directly from AdMobService.
- Active Android/iOS/lib release source contains no known Google sample publisher/ad-unit identifiers.
- Ad IDs must always be taken from canonical repo source; do not rely on memory or partially redacted historical output.
- AdMobService remains the authoritative runtime ad owner.
- UMP consent + Mobile Ads initialization + non-Premium entitlement remain mandatory before an ad request can proceed.
- Gate 8 remains open pending final two-device release smoke verification and release-policy closure.

### MON-M6.8R Verified platform AdMob mapping correction
- Production AdMob dashboard screenshots proved the existing runtime platform ad-unit mapping was incorrect.
- Correct Android production units:
  - App Open: ca-app-pub-8707491489514576/5736358977
  - Banner: ca-app-pub-8707491489514576/7416449761
  - Interstitial: ca-app-pub-8707491489514576/3438849765
  - Native Advanced: ca-app-pub-8707491489514576/3748489887
  - Rewarded Interstitial: ca-app-pub-8707491489514576/5061571550
  - Rewarded: ca-app-pub-8707491489514576/6804213858
- Correct iOS production units:
  - App Open: ca-app-pub-8707491489514576/7498939737
  - Banner: ca-app-pub-8707491489514576/9591267529
  - Interstitial: ca-app-pub-8707491489514576/8812021403
  - Native Advanced: ca-app-pub-8707491489514576/2837639998
  - Rewarded Interstitial: ca-app-pub-8707491489514576/8114534323
  - Rewarded: ca-app-pub-8707491489514576/7894240148
- Banner async completion now rechecks centralized canLoadAds and disposes stale advertising when entitlement or consent changes in flight.
- Platform AdMob App IDs (~ identifiers) remain unchanged until separately verified.
- Permanent release contract protects the verified unit inventory.

### MON-M6 Gate 8 AdMob + Premium suppression — CLOSED
- Gate 8/15 closed after static verification and physical Android + iPhone smoke testing.
- Physical Android: no unexpected ads appeared.
- Physical iPhone: no unexpected ads appeared.
- User directly confirmed no ads on both devices.
- Current release has zero external banner/interstitial/rewarded presentation callers.
- Ad production banner presentation is active and physically verified.
- Ad-Free is not user-facing Premium marketing.
- Serialized/model compatibility identifiers for adFree may remain where needed for backward compatibility.
- AdMobService remains fail-closed on unresolved/Premium entitlement and UMP consent.
- Platform-specific Android/iOS production ad units are corrected and release-contracted.
- Android/iOS AdMob App IDs are independently configured.
- Active release source contains no known Google sample/test identifiers.
- Future ad activation requires release-contract, mission-log, Android, and iPhone verification.


### MON-AUDIT-2026-09-13 — fresh HEAD and end-to-end monetization audit

**Status: audit performed; MON-X shared access policy corrected locally; monetization NOT release-ready.**

#### Baseline and evidence boundaries
- Canonical branch only: `release/central-integration-20260720`. `git fetch origin release/central-integration-20260720` succeeded; local HEAD and fetched remote both resolved to `0b72cd92923f0124601302309612df5729564bdb`.
- Existing checkout contains substantial staged, unstaged, and untracked work. This audit preserved it, did not switch/create branches, and did not stage, commit, push, or deploy. Pre-existing monetization implementations and ledger closures are working-tree evidence, not all committed HEAD behavior.
- `git show HEAD:lib/features/premium/models/subscription_models.dart` confirmed the expiry/flag defect exists at HEAD too. `git show HEAD:services/receipt-service/src/index.ts` confirmed the persisted-status and per-user entitlement architecture also exists at HEAD.
- Existing index binary diff SHA-256 before/after changes: `de8fb3413bb735541542c93ddfb1f590a2f0eb926522764f39ad68f861f757ba`. No parallel mission document was created.
- Historical physical confirmations above remain historical. This run did not perform purchases, restores, store-console catalog inspection, production deployment verification, or Android/iPhone physical tests.

#### End-to-end findings (working-tree source unless explicitly HEAD)
1. **Catalog / checkout:** `lib/features/premium/services/subscription_service.dart:178` queries actual store products; `:299` constructs the store purchase request. Receipt configuration is HTTPS-only in `receipt_validation_service.dart`; catalog absence does not fabricate products. Actual release configuration, localized prices and physical checkout remain unverified in this run.
2. **Identity / receipt ownership — OPEN blocker:** client receipt requests use authenticated identity, and backend entitlements are written under that UID. However `services/receipt-service/src/index.ts:590,750,926` validates store transactions then persists for the requesting UID without a demonstrated global transaction-owner claim or store account binding. `PurchaseParam` has no application account identifier. UID-scoped reads alone do not prove that one valid receipt cannot be replayed into two app accounts. Require an atomic ownership policy and real restore/migration semantics before claiming ownership closure.
3. **Lifecycle / revocation — OPEN blocker:** Apple/Google validation in `index.ts:590,750` checks provider lifecycle on validation. `handleSubscriptionStatus` at `:961` reads stored active/expiry fields and does not requery the store. No notification/reconciliation path is present in this service's route dispatch. Consequently earlier lifecycle closure does not establish prompt refund/revocation or renewal propagation. Apple grace handling also rejects an already-expired transaction before considering grace-period expiry; verify and correct with signed provider evidence.
4. **Cache authority — OPEN blocker:** `receipt_validation_service.dart:124` reduces subscription status to a boolean. `subscription_service.dart` `_loadBackendVerifiedSubscription` then reinstates the cached candidate, including its local expiry/flags. Backend response must eventually provide the canonical entitlement projection; persisted local fields must not determine renewed validity or paid capabilities. Account-transition asynchronous publication also requires a behavioral race audit; provider generation checks currently follow some state assignment.
5. **Premium capability enforcement — MON-X ACTIVE:** `UserSubscription.canAccessFeature` previously returned raw flags even for expired/free subscriptions; missing Premium expiry was considered valid. Provider convenience getters also returned raw flags. This defect was reproduced structurally at HEAD and corrected in this checkpoint, with executable model tests below.
6. **Exports — OPEN blocker:** `lib/core/services/data_export_service.dart:61` exports PDF/CSV without an entitlement check; Settings calls it at `lib/features/settings/screens/settings_screen.dart:1515`. `export_import_service.dart:80,113` has additional CSV/PDF entry points without guards. A paywall label or upgrade dialog is insufficient. Enforce at execution and after asynchronous account changes; preserve genuinely free personal-data portability explicitly.
7. **AI / analytics — OPEN audit:** `/insights` and `/ai-coach` routing, insights/analytics screens, and `enhanced_ai_chat_service.dart:222` require a full route-to-service capability/quota map. This run found no complete enforcement chain in these inspected paths; shared access-policy repair does not close route/API enforcement or server-side free usage limits.
8. **Ads / consent — Gate 8 code follow-up REOPENED:** production banner presentation is active and physically verified by source search (no external `AdWidget`/banner/show callers). Existing `AdMobService` nevertheless cached `_consentAllowsAds`, and `showPrivacyOptions` did not refresh eligibility. Existing consent contracts exposed this real defect. Corrected below. Historical no-ad observations cannot prove consent revocation or future active-ad suppression.
9. **Backend protection / claims:** `firestore.rules` denies direct client access including entitlement writes. Premium paywall excludes Ad-Free and Priority Support claims. Backend test passes do not establish production credentials, store ownership, or refund correctness.

#### Implemented continuation: MON-X shared policy and consent correctness
- `subscription_models.dart:186,208`: Premium requires a future expiry; all feature decisions first require valid Premium, then the capability flag. Free, expired, cancelled, missing-expiry and ungranted capability cases fail closed.
- `subscription_service.dart:45,711,737`: service access additionally requires the current durable identity to own the active subscription; unlimited quota reporting uses the same access decision.
- `subscription_provider.dart:29,43,184`: provider access requires agreement with the authoritative service and initialized account; convenience getters no longer bypass policy via cached flags.
- `admob_service.dart:60`: every existing load/show guard reads `AdConsentService.instance.canRequestAds`, eliminating the duplicate consent cache.
- `ad_consent_service.dart:58,83`: privacy changes suppress eligibility immediately, await the actual form callback, then refresh UMP eligibility and privacy-options requirement. Failure leaves advertising denied.
- Added `test/features/premium/models/premium_capability_expiry_test.dart`: 20 behavioral cases cover every feature across free tier, missing/expired expiry, serialized round-trip, lifecycle status, and absent grants. Tests use local model fixtures only; no demo or substitute production backend was introduced.
- Reconciled old Premium source contracts with existing account-scoped method signatures and removal of unsupported Ad-Free/Priority Support claims. Updated the ad-suppression contract to require the single live consent owner; did not weaken the consent/privacy contract that found the defect.

#### Verification
- `npm run verify` in `services/receipt-service`: PASS, lint/typecheck/build, 9/9 tests, `SMOKE=PASS`.
- `npm test` in `functions`: PASS, TypeScript build and 50/50 tests.
- `flutter test test/features/premium test/release_contracts/monetization*`: PASS, 116/116 tests. Initial broader runs exposed stale source contracts and the real consent-refresh defect; those were corrected before the successful final rerun.
- `flutter analyze lib/features/premium lib/core/services/admob_service.dart lib/core/services/ad_consent_service.dart test/features/premium`: PASS, zero issues.
- `flutter build bundle --debug`: PASS after the final consent changes (exit 0). A debug bundle is not a signed Android/iOS release or physical store test.
- `git diff --check`: PASS. Full-repository test suite, full analyzer, signed mobile builds and physical purchase/refund/restore tests are not claimed.

#### Next verified mission order and Q4 2026+ update
1. **Release blockers first:** receipt ownership/replay isolation and authoritative backend status/renewal/refund/revocation projection; then complete MON-X execution guards for PDF/CSV, analytics and AI, including deep links, direct calls, account switches and offline failure. Retain the shared fail-closed policy implemented here.
2. **Before monetization sign-off:** real store catalog and signed build configuration verification; Android+iPhone purchase/restore, paid-through cancellation, expiry, refund, account switching and UMP privacy-change evidence. Recheck dormant ads if any presentation caller is activated. Do not mark these complete based on source contracts.
3. **Q4 2026, contingent on release closure:** notification/reconciliation observability, ownership migration/recovery and entitlement race coverage; then the previously recorded authentication redesign, preserving durable purchase identity. Dates are planning targets, not availability promises.
4. **Q4 2026+ deferred product work:** AI Health Coach and Stress Level remain unavailable until real data provenance, access enforcement, evaluation and physical acceptance are proven. Do not introduce sample health observations or unsupported medical claims to meet a roadmap date.
5. **2027+ candidates:** broaden validated analytics/reporting only after the canonical monetization path and release evidence are complete. Family/multi-user, healthcare integration, direct wearable sync and differentiated support remain uncommitted candidates, not current Premium benefits.


### MON-M7.3R2 — Gate 9 UMP / AdMob authority hardening

**Status:** ACTIVE — code/contracts green; physical acceptance still pending.

**Verified evidence — 2026-09-13**
- Authoritative UMP consent ownership is centralized; duplicate consent cache must not be reintroduced.
- Android and iOS production AdMob unit IDs were corrected against direct AdMob-console evidence.
- Platform-ID regression contract added.
- Gate 9 verification suite: 23/23 passed.
- Full release contracts: 206/206 passed.
- Full `flutter analyze`: no issues.
- Premium ad suppression remains fail-closed and tied to authoritative entitlement state.
- No progress percentage increase yet because physical Android+iPhone acceptance remains outstanding.

**Remaining Gate 9 acceptance**
1. Physical Android: UMP state/privacy-options/ad-request behavior.
2. Physical iPhone: UMP state/privacy-options/ad-request behavior.
3. Confirm Premium suppresses all eligible ad requests on physical devices before closing Gate 9.

**Q4 2026+**
- Q4 2026: finish physical monetization acceptance and production E2E.
- Q1 2027: measured consent/ad-fill/revenue telemetry review.
- Q2 2027+: optimize placements/frequency only from production evidence.

<!-- REL-H1-FINAL-START -->
### REL-H1 — Production Hardening — COMPLETE

Evidence:
- Flutter analyzer: 0 issues.
- Release contracts: 206/206 passed.
- Android RELEASE APK built successfully.
- Android release signer: `CN=Flow AI Upload, OU=Mobile Release, O=Flow AI`.
- Android verified release SHA-256: `c5b9a4a306e2351fa642e185f2b8bdb907996f0aa55d75a5a9cb176d508c2739`.
- Android installed APK hash matched the verified local release APK exactly.
- Android installed release verified non-debuggable and visually confirmed with no DEBUG banner.
- iOS RELEASE build previously completed successfully for arm64.
- Physical iPhone visually confirmed with no DEBUG banner.
- `debugShowCheckedModeBanner: false` enforced at both authoritative Flutter application roots.
- Global error ownership remains centralized under `ErrorHandler`.
- Home title alignment verified consistently across Android and iOS.
- Health access wording verified as `Access Granted`.
- Final production state: no DEBUG banner on either physical device.

Future backlog:
- Redesign and simplify the Flow Ai Login / Sign Up landing experience while preserving authoritative authentication ownership and current privacy/security behavior.
<!-- REL-H1-FINAL-END -->

<!-- MON-9-IOS-PROOF-START -->
### MON-9 — UMP / Production Ad Delivery — PHYSICAL EVIDENCE

- Single shared `AdWidget` presentation owner verified in `MainShell`.
- Single UMP `ConsentInformation` owner retained.
- Premium entitlement remains authoritative and ads fail closed until entitlement is resolved.
- AdMob/UMP readiness lifecycle is observable by the shared presentation owner.
- Flutter analyzer: 0 issues.
- Release contracts: 206/206 passed.
- Physical iPhone: Flow Ai 2.2.4 (`1783342117`), bundle `com.flowai.health`.
- iPhone launched from the installed production app without rebuilding.
- Physical iPhone production banner ad visually confirmed on the authenticated non-Premium experience.
- Own ad was not clicked.
- Android lifecycle repair is complete, but Android physical production-ad visibility remains deferred and is not claimed as verified.
<!-- MON-9-IOS-PROOF-END -->

<!-- MON-9-FINAL-START -->
### MON-9 — UMP Consent + Production Ad Delivery — COMPLETE

- One authoritative `AdWidget` presentation owner in `MainShell`.
- One authoritative `BannerAd` factory in `AdMobService`.
- One UMP `ConsentInformation` owner.
- Premium entitlement suppresses ads and unresolved entitlement fails closed.
- AdMob/UMP readiness propagates to the presentation owner.
- Flutter analyzer: 0 issues.
- Release contracts: 206/206 passed.
- Physical iPhone: production banner visually confirmed on non-Premium authenticated Home.
- Physical Android: production banner visually confirmed on non-Premium authenticated Home.
- Android installed APK matched the verified RELEASE APK by SHA-256.
- Android installed package verified non-debuggable.
- Stray debug APK/session was identified as originating from plain `flutter run`, removed, and RELEASE restored.
- Own ads were not clicked during verification.
<!-- MON-9-FINAL-END -->

<!-- MON-10-FINAL-START -->
### MON-10 — Startup / Offline / Failure Resilience — COMPLETE

- Backend entitlement verification now distinguishes ACTIVE / INACTIVE / UNKNOWN.
- ACTIVE preserves authoritative Premium.
- INACTIVE removes Premium and falls back to Free.
- UNKNOWN cannot manufacture or extend Premium.
- UNKNOWN may preserve only a previously persisted, same-user, locally valid and unexpired Premium entitlement.
- Temporary backend/network failure is no longer treated as authoritative expiry/revocation.
- Purchase/restore failure paths remain fail-closed.
- Focused subscription validation policy tests: 13/13 passed.
- Release contracts: 206/206 passed.
- Flutter analyzer: 0 issues.
- Physical iPhone and Android offline/startup verification completed with Flow Ai remaining usable and no visible errors.
- Ads remained visually present during the physical check; this is recorded only as observed UI state, not proof of a fresh network ad request while offline.
<!-- MON-10-FINAL-END -->

<!-- MON-11-CLOSURE-START -->
### MON-11/15 — Analytics / Logging / Privacy — COMPLETE

Status: COMPLETE — 2026-09-13

Authoritative evidence:
- Production telemetry ownership is centralized in `ProductionAnalyticsService`.
- Analytics collection remains fail-closed by default with `_analyticsEnabled = false` until explicit persisted consent.
- Auth account scope is bound through `setAuthenticatedUser`; raw analytics user identity is not persisted in the production telemetry owner.
- Raw `user_id`, `transaction_id`, and `original_transaction_id` telemetry payload leakage identified during MON-11 was removed from the relevant production/compatibility paths.
- Production logging that exposed raw `userId` values was sanitized.
- `AdvancedAnalyticsService` was proven unreachable through repository-wide caller/import/provider/type/storage-key audits and retired as a conflicting parallel telemetry owner.
- Legacy `AnalyticsService` / `AnalyticsProvider` remain because repository evidence proves they serve active local calculation/UI responsibilities rather than production telemetry transport.
- `SubscriptionAnalyticsService` remains only as a non-authoritative compatibility surface; it does not own production telemetry transport.
- `monetization_analytics_privacy_ownership_contract_test.dart`: 4/4 passed.
- Existing compliance/account-isolation privacy validation: 5/5, 5/5, and 4/4 passed in the final MON-11 validation sequence.
- Full release-contract suite: 210/210 passed.
- `flutter analyze`: 0 issues.
- Staged Git index remained unchanged through the guarded final mutation/validation.
- No debug build/deployment path was used.

MON-11 closure:
- MON-11.1 Analytics ownership + PII leakage — COMPLETE.
- MON-11.2 Production logging + transaction identifiers — COMPLETE.
- MON-11.3 Analytics architecture / consent integrity — COMPLETE.
- MON-11.4 Tests + evidence closure — COMPLETE.

Monetization gate progress after closure: 11/15 = 73%.
<!-- MON-11-CLOSURE-END -->


### MON-9.1 — Smart ad placement truth hardening

**Status:** COMPLETE — 2026-09-14.

**Verified production policy**
- Banner presentation is route-aware and limited to Home and Insights for eligible non-Premium users after authoritative UMP consent and entitlement resolution.
- Interstitial presentation has one audited natural transition: Insights → Home.
- Interstitial protection includes a 2-minute session grace period and a 10-minute cooldown.
- Calendar/cycle, tracking, Health/biometrics, authentication/onboarding, Premium/purchase/restore, settings/privacy/account and partner flows have no direct ad presentation.
- Rewarded remains dormant because no truthful bounded value exchange currently exists. The dead runtime `PremiumInsightsUnlockCard` and unsupported rewarded-insight copy were retired rather than manufacturing a reward.
- App-open, Native and Rewarded-interstitial remain disabled because the current product layout provides no justified production placement.
- Active Insights was repaired to use authoritative real-data analytics owners and fail closed when recorded history is insufficient; synthetic analytics claims were removed.

**Verification**
- `flutter analyze`: PASS, zero issues.
- `flutter test test/release_contracts`: PASS, 222/222.
- Sensitive direct-ad presentation scan: zero hits.
- Rewarded runtime presentation callers: zero.
- Staged index preservation: PASS.
- This hardening does not change the closed monetization gate count; Monetization remains 11/15 (73%) until MON-12 closes.


### MON-12.3 — App Store distribution-signing proof

#### Deep dependency/reachability evidence — current release
- Full transitive Dart import graph is being derived from `lib/main.dart`; symbol-name grep is not accepted as dependency proof.
- Six pending tracked deletions are classified only from exact production import/path reachability plus analyzer/contracts:
  - `biometric_integration_service.dart`
  - `smart_notification_service.dart`
  - `advanced_analytics_service.dart`
  - `biometric_dashboard_screen.dart`
  - `premium_insights_unlock_card.dart`
  - `consumer_intelligence_dashboard.dart`
- `EnhancedConsumerDashboard` contains mock/demo health values but has no caller or route in the audited current source and is classified DEAD_CODE; it is not being rewritten during the current release.
- Placeholder/mock code is a release blocker only when proven reachable from the production entrypoint and capable of presenting fabricated runtime truth.
- Truthful Coming Soon/upcoming-feature UI remains allowed.
- Debug deployment remains prohibited; compile-time `kDebugMode` branches are not themselves release evidence or a blocker unless reachable production behavior is unsafe.
- Current baseline after the deep audit: `flutter analyze` 0 issues; release contracts 238/238.


**Status:** TECHNICALLY PROVEN — 2026-09-14.

This artifact is **distribution-signing evidence only**, not the final App Store submission artifact. Product/release work remains open, so a fresh final IPA must be produced after all remaining release work and physical verification are complete.

**Evidence**
- IPA: `build/ios/ipa/flow_ai.ipa`
- SHA-256: `45cc3997fb5fe952cb29f611d6bea4c63dd5cbc876c068ac609fa9b851c4c1c5`
- Bundle identifier: `com.flowai.health`
- Version/build: `2.2.4 (1783342117)`
- Signing authority: `Apple Distribution: Geoffrey Rono (9FY62NTL53)`
- Team identifier: `9FY62NTL53`
- Embedded profile: `FlowAI App Store 2.2.1`
- Application identifier: `9FY62NTL53.com.flowai.health`
- `get-task-allow=false`
- Dart debug / VM-service markers: zero
- `flutter analyze`: zero issues
- Release contracts: 222/222 passed
- Staged index preservation: PASS

**Release rule**
Do not upload or submit this proof artifact. After all remaining product work is complete, rebuild and re-run the same distribution/binary verification against the actual final release candidate.

### 48-hour release scope — deferred localization expansion
- Flow Ai retains its existing 36-language capability.
- Full localization parity across every feature is not required for the immediate release.
- Remaining localization coverage/parity work is explicitly deferred to a future release and must not block the current 48-hour release candidate.

<!-- FLOW_48H_RELEASE_CONTROL_START -->
## 48-hour release control snapshot — 2026-09-14

### Authoritative current progress
- General: 71%
- Monetization: 73%
- Identity & Cloud: 60%
- Wellness/Health: 100%

### Monetization mission order
1. MON-1 Entitlement ownership — COMPLETE
2. MON-2 Account switch / stale callback isolation — COMPLETE
3. MON-3 Receipt backend/routes — COMPLETE
4. MON-4 Durable purchase identity — COMPLETE
5. MON-5 Subscription lifecycle — COMPLETE
6. MON-6 Store products + Apple/Google configuration — COMPLETE
7. MON-7 Premium feature claims and authoritative gating — COMPLETE
8. MON-8 AdMob + Premium suppression — COMPLETE
9. MON-9 UMP/consent/privacy options — COMPLETE
10. MON-10 Startup/offline/failure behavior — COMPLETE
11. MON-11 Analytics/logging/privacy — COMPLETE
12. MON-12 Android+iOS final release integrity — 95%; final frozen-candidate physical verification remains

### Restore Purchases UX — CURRENT RELEASE
- Classification: ACTIVE — source gate CLOSED WITH EVIDENCE; physical Android+iPhone restore verification remains.
- `SubscriptionService.restorePurchases()` remains the sole store-restore authority.
- Existing `_restoreCompleter` remains the single service-level concurrent-restore guard.
- `SubscriptionProvider` now owns operation-specific `isRestoring` presentation state.
- Premium paywall shows immediate spinner + `Restoring…` only during a real restore operation.
- Generic `isLoading` still disables conflicting Premium actions while restore is active.
- Receipt validation, durable identity checks, entitlement authority, timeout behavior, and restore result semantics are unchanged.
- Source verification evidence:
  - initial Restore UI contract run exposed a TEST_ONLY harness defect: provider source was asserted without being loaded
  - production Restore source was not implicated by that failure
  - existing contract was repaired in place; no duplicate test was created
  - provider/UI Restore contract passed
  - monetization authority contracts passed
  - `flutter analyze` passed with 0 issues
  - full release-contract suite passed
  - store/receipt/entitlement authority remained unchanged
  - staged index remained protected throughout
- Required closure: targeted contracts, analyzer, full release contracts, then physical Android and iPhone restore verification.

13. MON-13 Android purchase/restore — 100% — CLOSED
14. MON-14 iPhone purchase/restore — RECALCULATION PENDING; physical Restore Purchases PASS; fresh physical purchase gate remains
15. MON-15 Final E2E regression — 65%; final frozen-candidate regression remains

### Verified release-hardening work
- Analyzer: zero issues.
- Release contracts: 235/235 passing at latest static baseline.
- Wellness/Health static truth work remains closed at 100%.
- Account deletion static ownership and deletion policy are closed with backend identity deletion and client fail-closed verification.
- Daily Feelings Save artificial 1600 ms presentation delay removed.
- Daily Feelings Save now uses immediate frosted-glass presentation while preserving the existing `_saveEntry()` persistence owner.
- Public support copy no longer claims unsupported 95%+ prediction accuracy, PCOS/Endometriosis detection, full localization parity, or seamless Web sync.
- Existing 36-language capability remains supported; full localization parity is deferred.
- `lib/core/config/build_config.dart` is classified DEAD/NON-PRODUCTION: no external import/runtime consumer was proven; its localhost development URL is not release-critical.
- Dormant Partner AI insight generation remains deferred; no fabricated runtime Partner insights are shown.
- Legacy Premium usage-counter persistence remains non-authoritative/dead runtime and is deferred.

### Physical verification already observed
- Android and iPhone release-mode deployments have launched successfully during this release-hardening cycle.
- Home, Health, Insights, Premium UI, ads and general navigation were reported working without crashes or DEBUG banners before the latest Daily Feelings UI change.
- Test purchase/unlock behavior has worked.
- Final physical verification must be repeated against the final frozen source after all code changes are complete.

### Explicitly open before release
- Physical verification of the new Daily Feelings frosted-glass Save interaction.
- MON-12.4 final frozen-source Android+iPhone smoke verification.
- MON-13 Android Restore Purchases verification.
- MON-14 iPhone Purchase/Restore — CLOSED/PASS on physical Release iPhone.
- MON-15 final E2E regression.
- One final AAB + IPA build only after all remaining source changes are finished.
- Final signing/hash verification of those frozen store artifacts.

### Deferred — not forgotten
- Full localization parity across the existing 36-language capability.
- Login/sign-up UX redesign.
- Dormant Partner AI generation.
- Dead legacy Premium usage-counter persistence cleanup.
- Dead experimental health/visualization owners.
- Flutter SDK upgrade only after release.
<!-- FLOW_48H_RELEASE_CONTROL_END -->

### UX-1 — App-wide Scroll Physics Parity — FUTURE
- Android pages should inherit premium drag/bounce/spring behavior centrally rather than page-by-page.
- One authoritative ScrollBehavior/ScrollPhysics owner must govern eligible app scrollables.
- Must be regression-tested across Android and iOS before closure.

### UX-2 — Swipeable Section Capsules — ACTIVE
- Current-release requirement: Track Flow / Symptoms / Mood / Pain / Notes must remain horizontally swipeable on constrained widths without clipping or rigid compression.
- Authoritative shared horizontal-physics owner: `AppHorizontalSelectorBehavior`.
- Authoritative shared segmented-control owner: `AppSegmentedSelector`.
- Track now delegates capsule presentation to `AppSegmentedSelector`; the previous duplicate Track `TabBar` presentation has been removed.
- `AppSegmentedSelector` centrally owns:
  - horizontal scrolling
  - bounce physics
  - intrinsic-width labels
  - selected state
  - optional icons
  - accessibility semantics
  - optional emphasized indices
- Existing Track `TabController` / `PageController` synchronization is preserved.
- Both pre-existing UX-2 contracts were updated in place; no duplicate contract file was created.
- The obsolete rigid `isScrollable: false` / `TabAlignment.fill` expectation was removed because it contradicted the approved swipeable behavior.
- `_buildTabContent()` reachability audit proved exactly one occurrence — its own definition — before deletion.
- `_buildTabContent()` was removed only after that proof.

#### Verification evidence
- targeted UX-2 contracts: 9/9 passed
- cycle feature suite: 225/225 passed
- `flutter analyze`: 0 issues
- full release contracts: 238/238 passed
- staged Git tree unchanged during audit/mutation/verification
- staged patch SHA unchanged during audit/mutation/verification

#### Remaining closure gate
- Physical Android Track verification on final frozen source.
- Physical iPhone Track verification on final frozen source.

Status: ACTIVE — source work CLOSED WITH EVIDENCE; physical two-device verification remains.
### Permanent architecture rule — centralized ownership
- Every reusable function, feature, action, interaction pattern, visual control, service, state owner, persistence path, monetization path, health owner, selector, dialog, and scroll behavior must have one authoritative owner.
- Screens and feature modules delegate to shared owners instead of creating parallel implementations.
- Cross-app improvements must be implemented at the highest safe shared owner so one fix propagates consistently across all eligible screens.
- Duplicate owners are release defects unless explicitly justified by platform/runtime requirements.


#### MON-12 deep dependency audit — CLOSED WITH EVIDENCE
- Production dependency graph resolved transitively from `lib/main.dart`, including conditional Dart import/export URIs: 211 reachable source files.
- Current baseline after dependency audit:
  - `flutter analyze`: 0 issues
  - release contracts: 238/238 passed
  - staged index unchanged
- The following tracked deletions are accepted as SAFE_RETIREMENT for the current release because each deleted file is absent from the production dependency graph and has no exact production import/path ownership:
  - `lib/core/services/biometric_integration_service.dart`
  - `lib/core/services/smart_notification_service.dart`
  - `lib/features/analytics/services/advanced_analytics_service.dart`
  - `lib/features/biometric/screens/biometric_dashboard_screen.dart`
  - `lib/features/cycle/widgets/premium_insights_unlock_card.dart`
  - `lib/features/insights/screens/consumer_intelligence_dashboard.dart`
- Identifier matches such as `TrendDirection`, `TimeOfDay`, `PersonalizedRecommendation`, and similar names were proven insufficient dependency evidence because those identifiers are independently defined/used elsewhere; they do not import the deleted owners.
- Retirement/absence contracts additionally support the notification, analytics, and Premium Insights retirements.
- Production-reachable placeholder audit found no fabricated demo/mock-data release blocker.
- `AuthService` handling of platform `NotImplemented` is a truthful error/failure path, not simulated functionality.
- Truthful `Coming Soon`, future-feature status, form placeholders, and loading placeholders remain allowed.
- Dead experimental/mock-heavy source that is not reachable from the production entrypoint is deferred; it will not consume current-release time unless later evidence makes it reachable.
- Deletion and runtime-placeholder questions are CLOSED; do not reopen without contradictory new evidence.


#### MON-12 legacy tooling classification — CLOSED WITH EVIDENCE
- `functions/test/callable_architecture.test.cjs` is REQUIRED_TEST: owned by the Functions `npm test` script, invoked by release validation, and passes.
- `support/index.html` is RELEASE_SUPPORT: tracked compliance/release asset and valid support HTML.
- `run.sh` and `run_iphone16plus.sh` are retired fail-closed legacy simulator/debug runners.
- `fix_pods.sh` and `scripts/fix_build_issues.sh` had no runtime/CI caller and contained broad destructive or environment-mutating repair behavior; both are now retired fail-closed rather than retained as release shortcuts.
- No debug runner, broad Flutter upgrade, broad build mutation, destructive CocoaPods reset, or automatic SDK rewrite is permitted as part of the current release path.


#### UX-2 platform typography architecture — ACTIVE
- Android root: `MaterialApp.router` using centralized `AppTheme.lightTheme` / `AppTheme.darkTheme`.
- iOS root: `CupertinoApp.router` using `CupertinoThemeData`.
- Current iOS root has no explicit `CupertinoTextThemeData`.
- Current iOS root also has no proven centralized Material `Theme` bridge for Material-based feature screens.
- Health does not own platform font sizing; it consumes semantic Material text tokens through `Theme.of(context)`.
- Flow Ai Material typography is centralized in `lib/core/theme/app_theme.dart`.
- Platform typography must therefore be solved at the app/theme ownership layer, never through per-screen Android/iOS font constants.
- Historical iOS sizing policy is being recovered before mutation so intentional display-space decisions are preserved.
- Future scaling rule: platform typography policy -> one centralized owner -> semantic text tokens -> features consume tokens only.


#### UX-2 typography centralization/scaling contract — ACTIVE
- Platform typography is infrastructure, not feature-local styling.
- Authoritative ownership must remain centralized at the app/theme layer.
- Health, Home, Insights, Settings, Premium and future feature screens consume semantic typography tokens and must not introduce independent Android/iOS font-size constants.
- Every platform-specific typography rule must document:
  - authoritative source file/owner
  - reason for the platform difference
  - semantic tokens affected
  - display-space/accessibility constraints
  - Android + iPhone physical evidence
  - release contracts protecting the ownership rule
  - instructions for future scaling/change
- Current investigation has not proven an explicit historical numeric iOS font-scale value; no value will be invented.
- The exact Cupertino-root introduction and its parent architecture are being compared before mutation.


#### UX-2 centralized platform typography — IMPLEMENTED
- Authoritative typography owner: `lib/core/theme/app_theme.dart`.
- Android remains on the existing Flow Ai Material `TextTheme`.
- iOS retains its current measured Material presentation under `CupertinoApp.router`, but the previously implicit framework fallback is now explicit through `AppTheme.iosMaterialTextTheme`.
- Exact measured iOS Material values preserved:
  - headlineLarge 32
  - headlineMedium 28
  - headlineSmall 24
  - titleLarge 22
  - titleMedium 16
  - titleSmall 14
  - bodyLarge 16
  - bodyMedium 14
  - bodySmall 12
- `lib/main.dart` is the platform-root bridge: the iOS Cupertino root wraps Material feature content in the centralized iOS Material theme.
- Feature screens must consume semantic theme tokens only; no Android/iOS font constants belong in Health, Home, Insights, Settings, Premium, or future screens.
- Future typography changes must be made at the centralized AppTheme/platform-root ownership layer and protected by release contracts plus Android+iPhone physical evidence.


#### UX-2 iOS typography property-preservation correction — CLOSED WITH EVIDENCE
- Physical iPhone verification exposed unreadable text after the initial centralized typography bridge.
- Root cause: the first iOS `TextTheme` implementation replaced complete Flow Ai semantic styles with bare `TextStyle(fontSize: ...)` objects, discarding inherited color, weight, spacing, height and related properties.
- Correct authoritative implementation remains `lib/core/theme/app_theme.dart`.
- iOS now starts from the complete Flow Ai light/dark `TextTheme` and uses `copyWith` only for the exact measured platform font sizes.
- Exact iOS sizes remain unchanged: headlineLarge 32, headlineMedium 28, headlineSmall 24, titleLarge 22, titleMedium 16, titleSmall 14, bodyLarge 16, bodyMedium 14, bodySmall 12.
- Light and dark themes each preserve their own semantic style properties.
- Future platform typography changes must modify semantic token properties through the centralized base-theme copy policy; replacing complete `TextStyle` tokens with size-only styles is prohibited.


#### UX-2 Settings header geometry correction — CLOSED WITH EVIDENCE
- Physical iPhone verification exposed a missing Settings title and excessive blank top region.
- Settings already owns the system inset through `SafeArea`.
- The previous `SliverAppBar` + `expandedHeight: 96` + `FlexibleSpaceBar` created a second platform-sensitive header geometry layer.
- Settings now uses a fixed `SliverToBoxAdapter` header inside the existing `SafeArea`.
- Header typography uses centralized `theme.textTheme.titleLarge`; Settings owns no platform-specific font size.
- Future Settings changes must retain one system-inset owner and one header-layout owner.


### UX-2 numbered user-reported visual findings ledger

- **UX2-F01 — iOS typography regression — FIX IMPLEMENTED / PHYSICAL RECHECK PENDING**
  Physical iPhone verification showed titles/text becoming invisible after the initial iOS Material typography bridge. Root cause was loss of inherited semantic TextTheme properties. The centralized source correction preserves complete Flow Ai semantic styles and overrides only exact measured iOS font sizes.

- **UX2-F02 — iOS Settings top-bar/header geometry — FIX IMPLEMENTED / PHYSICAL RECHECK PENDING**
  Physical iPhone verification showed the Settings title missing with excessive blank top/header space. The expanded `SliverAppBar` / `FlexibleSpaceBar` geometry was replaced by a fixed header inside the existing `SafeArea`.

- **UX2-F03 — Android Settings header icon/carrier oversized and visually unappealing — OPEN**
  User reports the Settings header icon/carrier is too large on Android and does not match the desired Flow Ai visual hierarchy. Do not guess replacement dimensions; use exact existing shared geometry after source verification.

- **UX2-F04 — iOS Calendar `No active cycle` truncation — OPEN**
  User reports the Current Cycle summary at the bottom of Calendar truncates `No active cycle`. Source owner is the Calendar landing summary card. Fix must preserve localization and responsive layout rather than shortening the text.

- **UX2-F05 — Daily Feelings light-mode top carrier too saturated — OPEN**
  User reports the Daily Feelings top holder/carrier in light mode uses excessively deep/saturated colors and does not match the Flow Ai light-theme surface hierarchy. Audit the authoritative carrier/color owner and soften only light mode while preserving dark mode and shared theme ownership.

- **UX2-F06 — iOS Track date/header contrast — FIX IMPLEMENTED / PHYSICAL RECHECK PENDING**
  Physical iPhone screenshot showed date/header text with poor contrast after the typography bridge. Centralized typography property-preservation correction implemented; physical release verification remains required.

- **UX2-F07 — iOS Flow `None` state contrast — FIX IMPLEMENTED / PHYSICAL RECHECK PENDING**
  Physical iPhone screenshot showed the `None` flow state nearly invisible. Centralized typography property-preservation correction implemented; physical release verification remains required.

- **UX2-F08 — iOS Track bottom content clearance / `Very Heavy` — OPEN**
  Physical screenshot indicated lower flow content may be clipped or visually obstructed near bottom navigation. Verify source bottom-clearance ownership and physical release behavior before closure.

- **UX2-F09 — Cross-platform typography architecture — ACTIVE RULE**
  iOS intentionally uses the exact measured larger Material typography tokens while Android keeps the established compact Flow Ai Material typography. Platform differences belong in centralized theme ownership, never feature-screen magic numbers.

- **UX2-F10 — Exact-measurement rule — ACTIVE RULE**
  Never estimate font sizes, dimensions, spacing differences, percentages or geometry. Use exact source values, widget measurements or physical evidence; otherwise state that the value is not yet measured.

#### UX-2 capture discipline
Every new user-reported defect, suggestion, visual preference, architectural concern or verified engineering finding must receive a stable numbered identifier, status and evidence in this existing mission ledger. Items remain OPEN until implementation plus required automated and physical evidence proves closure. Do not silently drop, merge away or mark an item complete without evidence.


#### UX2-F11 — Swipe-selected capsule auto-follow — SOURCE VERIFIED / PHYSICAL RECHECK PENDING
- Physical/user feedback showed that swiping Track body pages could advance beyond the currently visible horizontal capsules while the selected capsule remained off-screen.
- Exact source audit proved `TrackingScreen.onPageChanged` correctly updates `_tabController`, while the shared `AppSegmentedSelector` previously had no mechanism to reveal a newly selected off-screen item.
- Authoritative fix belongs in `lib/core/ui/app_segmented_selector.dart`, not in Track-specific code.
- The shared selector now automatically scrolls only enough to keep the externally selected capsule visible.
- Existing selector API, intrinsic label widths, horizontal scrolling, geometry, semantics and Track `PageView` ownership remain unchanged.
- Release contract protects programmatic/page-driven selection visibility.
- Physical Android+iPhone verification remains required before closure.

#### UX2-F12 — Top-level page-title typography consistency — SOURCE VERIFIED / PHYSICAL RECHECK PENDING
- Active-route audit confirmed Settings, Calendar and Insights are live top-level screens.
- Settings used `titleLarge`; Calendar and Insights used `headlineMedium`, producing inconsistent platform-dependent title sizes.
- Settings approved geometry remains unchanged.
- Calendar and Insights now use the same `titleLarge` semantic page-title token as Settings.
- No app-wide hard-coded font-size replacement was performed.
- Android+iPhone physical verification remains required.

#### UX2-F13 — iOS Insights learning subtitle single-line integrity — SOURCE VERIFIED / PHYSICAL RECHECK PENDING
- `learnYourPatterns` is the authoritative localized source for `Powered by Machine Learning`.
- The subtitle shares horizontal header space with the fixed AI Powered badge.
- Subtitle now uses existing semantic `bodyMedium`, `maxLines: 1`, and no wrapping.
- No guessed numeric font size was introduced.
- iPhone physical verification remains required.


#### UX2-F14 — Centralized platform page-title sizing — CLOSED WITH EVIDENCE
- Android retained title target: exact previous Calendar size, 20 px.
- iOS retained title target: approved current page-title size, 22 px.
- User physically approved current iOS Settings and Insights typography on 2026-09-15.
- iOS `Powered by Machine Learning` is physically verified on one line.
- Track selected capsule auto-follow is physically verified through Notes.
- iOS title appearance must not regress.
- Android physical recheck remains required before full closure.


#### UX2-F15 — Stale page-title contracts after centralization — CLOSED WITH EVIDENCE
- Page-title production ownership moved from per-screen `titleLarge.copyWith(...)` blocks to centralized `AppPageTypography.title(context)`.
- Two release contracts still asserted the retired local implementation and caused the targeted gate to fail.
- Contracts were updated to assert the authoritative shared owner rather than reverting production code.
- Targeted tests, analyzer and full release contracts are required evidence for closure.


#### UX2-F16 — Duplicate Insights title styling — CLOSED WITH EVIDENCE
- Deep audit found a second `AI Insights` title in the same live screen still using local `titleLarge.copyWith(...)`.
- It was centralized to `AppPageTypography.title(context)`.
- Targeted contract, analyzer and full release contracts passed.


#### UX2-F17 — Home page-title typography centralization — CLOSED WITH EVIDENCE
- Deep audit confirmed the live Home AppBar title still used a local `titleLarge` style.
- Home now delegates its top-level page title to `AppPageTypography.title(context)`.
- Greeting typography and Health Data score typography remain unchanged because they are component-level styles, not page titles.
- Home now follows the same proven page-title sizing as Settings, Calendar and Insights: Android 20 px / iOS 22 px.
- Physical Android verification remains required before closure.


#### UX2-F18 — Stale Home title density contract — CLOSED WITH EVIDENCE
- Home AppBar title was correctly centralized to `AppPageTypography.title(context)`.
- `mission6_home_section_title_density_contract_test.dart` still asserted the retired local `titleLarge.copyWith(...)` implementation.
- The stale contract was updated to assert the authoritative centralized owner.
- Home greeting, Health Data score, prediction values and other component typography remain untouched.
- Targeted contract, analyzer and full release contracts passed before closure.


#### Android physical title verification — 2026-09-15 — CLOSED WITH EVIDENCE
- User physically verified Home title sizing is correct.
- Home, Settings, Calendar and Insights now share the centralized `AppPageTypography` owner.
- Android retained page-title size is 20 px.
- Approved iOS page-title size remains 22 px.


#### UX2-F19 — Track weekday and None-flow contrast — SOURCE VERIFICATION ACTIVE
- Deep audit proved Track weekday text used `onSurface` at 0.6 alpha.
- Weekday now uses semantic `onSurfaceVariant`.
- Deep audit proved selected `None` inherited `AppTheme.lightGrey` as its selection accent, reducing contrast.
- `None` now uses the theme's authoritative `onSurfaceVariant` accent.
- No arbitrary color or opacity was introduced.
- `Very Heavy` clearance remains UX2-F08 and is not closed from static evidence; the Flow page is scrollable and no fixed-height/overlay cause was proven.


- 2026-09-15 physical verification: Android displays `Very Heavy` correctly by default.
- iOS does not fully expose `Very Heavy` until the user scrolls.
- Fix must therefore preserve Android and address only the proven iOS layout/clearance owner.


#### UX2-F20 — Track automatic persistence and save-bar retirement — DEFERRED / FUTURE RELEASE
- User requested replacing the persistent `Save Changes` action with automatic persistence after Track interactions.
- Current authoritative persistence owner is `_saveTrackingData()` in `tracking_screen.dart`.
- Deep audit proved the existing owner is single-flight: it returns immediately while `_isSaving == true`.
- Track contains both discrete inputs and high-frequency inputs:
  - Flow selections
  - symptom selections
  - symptom severity sliders
  - Mood/Energy controls
  - Pain controls
  - Notes / quick notes
- Calling the current save method from every input callback would be unsafe:
  - rapid changes can occur while a save is already in-flight;
  - the current guard can discard a subsequent save request;
  - sliders/text editing could create excessive database writes;
  - failure/retry and dirty-state semantics need authoritative handling.
- Do NOT implement naive callback-level autosave.

Future authoritative design requirements:
1. One centralized Track autosave coordinator/owner; no per-tab duplicate save logic.
2. Debounce high-frequency slider/text changes.
3. Immediate or near-immediate persistence for discrete selections where safe.
4. Coalesce changes into the newest complete Track snapshot.
5. Single-flight persistence with a pending-generation/revision mechanism so a change arriving during a save is never lost.
6. After a save completes, persist the newest pending revision before clearing dirty state.
7. Preserve `_hasUnsavedChanges` on failure and provide retryable error feedback.
8. Lightweight `Saving…` / `Saved` / `Unsaved` status replaces the large persistent CTA only after autosave is proven.
9. Flush pending changes safely on notes focus loss, date/page transition and relevant lifecycle events.
10. Add race/concurrency, rapid-slider, text-edit, failure/retry and physical Android+iPhone contracts before retiring `Save Changes`.
- This is intentionally deferred so the current release does not introduce persistence/data-loss risk.


#### MON12-AD1 — Android/iOS AdMob delivery discrepancy — P0 AUDIT ACTIVE
Physical AdMob dashboard evidence supplied 2026-09-15:

Android:
- requests: 180
- impressions: 108
- match rate: 66.67%
- estimated earnings: €0.05

iOS:
- requests: 2.88K
- impressions: 152
- match rate: 92.91%
- estimated earnings: €0.08

Release concern:
- Android is generating dramatically fewer ad requests than iOS.
- iOS additionally shows a large request-to-impression gap despite high match rate.
- Do not assume this is purely user-volume difference until runtime ownership, IDs,
  consent, Premium suppression, load/display lifecycle and route reachability are audited.
- Existing physical evidence confirms ads can render on both platforms.
- Do not disturb working AdMob behavior without a proven source defect.


#### MON12-AD2 — iOS matched-request / impression show-rate anomaly — P0 AUDIT ACTIVE
- AdMob dashboard evidence on 2026-09-15:
  - Android: 180 requests, 66.67% match rate, 108 impressions.
  - iOS: 2.88K requests, 92.91% match rate, 152 impressions.
- Derived matched-request/show funnel:
  - Android matched requests ≈ 120; show rate ≈ 90%.
  - iOS matched requests ≈ 2,676; show rate ≈ 5.7%.
- Therefore the primary unexplained anomaly is not Android fill alone.
- iOS is generating/receiving a very large number of matched ads that do not become impressions.
- Static audit already proves:
  - correct production platform App IDs/ad-unit IDs;
  - no Google demo/test ad-unit IDs in production;
  - authoritative UMP consent gating;
  - authoritative SubscriptionProvider Premium suppression;
  - banners restricted intentionally to `/home` and `/insights`;
  - analyzer clean and ad/monetization contracts passing.
- Next audit target: interstitial preload/reload frequency and all non-banner request paths.
- Do not change working banner delivery until exact request source is proven.


#### MON12-AD3 — Full-screen ad concurrent-load integrity — SOURCE FIX IMPLEMENTED / VERIFICATION ACTIVE
- Deep source audit found no in-flight guard around `InterstitialAd.load`.
- Interstitial loading can be requested from:
  - startup initialization;
  - free-entitlement resolution;
  - a show attempt when no ready interstitial exists;
  - dismissal/failure-to-show replenishment.
- Concurrent load callbacks can overwrite `_interstitialAd`; prior loaded objects are not explicitly disposed before replacement.
- Rewarded loading has the same structural weakness, though no active rewarded runtime caller has yet been proven.
- Banner ownership already has `_bannerLoadInFlight` and must not be changed without evidence.
- Before mutation, audit service instance ownership and exact preload callers.


Full-screen load hardening implementation:
- `AdMobService` remains the single authoritative ad owner.
- Interstitial and rewarded loading now use explicit in-flight guards.
- Ready ads prevent redundant preload requests.
- Each load receives a generation token.
- Ads returned from stale or no-longer-authorized callbacks are disposed instead of becoming active.
- Full-screen callbacks clear their owned ad reference before replenishment.
- Premium suppression / forced disposal invalidates pending generations.
- Banner ownership was intentionally left unchanged because `_bannerLoadInFlight` was already proven correct.
- No ad frequency, ad placement, route policy or production ad-unit ID was changed.


##### MON12-AD3 stale-callback ownership verification
- Stale interstitial/rewarded load callbacks now verify generation ownership before clearing the shared in-flight flag.
- A callback from an invalidated generation disposes its returned ad and cannot release ownership held by a newer request.
- The suppression release contract no longer depends on source-comment counts; it protects actual generation, in-flight, disposal and readiness state.


#### MON12-AD4 — MainShell banner request-churn integrity — SOURCE VERIFIED / PRODUCTION OBSERVATION PENDING
- Per-format reachability audit narrowed the unexplained AdMob request volume:
  - App-open and native units have IDs but no runtime ad owner.
  - Rewarded has service support but no proven active external show caller.
  - Interstitial presentation is restricted to Insights -> Home with session-age and cooldown gates.
  - Banner is the persistent reachable ad format on `/home` and `/insights`.
- Remaining high-priority question:
  whether `MainShell._syncBanner()` can dispose/recreate banners because of route,
  entitlement-readiness, widget rebuild or lifecycle churn.
- No banner mutation is authorized until exact lifecycle/call ownership is proven.
- Existing `_bannerLoadInFlight` protection must be preserved.


#### MON12-AD5 — Platform banner automatic-refresh parity — P0 EXTERNAL CONFIG AUDIT ACTIVE
- Google Mobile Ads banner units can automatically refresh while visible.
- Automatic refresh is configured at the AdMob ad-unit level, not in Flutter source.
- Android and iOS use separate production banner ad units, so refresh configuration can differ between platforms.
- This is a plausible external contributor to the large iOS request count and cannot be proven from repository source.
- Required evidence before closure:
  - Android banner ad unit Automatic refresh setting.
  - iOS banner ad unit Automatic refresh setting.
  - Compare Google optimized / custom interval / disabled.
- Do not alter refresh configuration until both platform settings are compared.


##### UX2-F08 viewport root-cause continuation
- Physical evidence: Android exposes `Very Heavy` correctly by default; iOS requires a scroll.
- Static layout audit proves the persistent Track save-action area is a sibling below the `Expanded(PageView)`.
- Therefore a visible save action removes vertical height from every Track page rather than floating outside page measurement.
- Autosave redesign remains deferred; no persistence semantics will be changed for this release.
- Current release investigation is limited to safe presentation/visibility behavior around the existing save action.
- Do not add arbitrary iOS padding: that would further reduce visible content.


##### UX2-F08 duplicated bottom SafeArea root cause
- Deep audit proved `TrackingScreen` used a default `SafeArea`, including bottom system inset.
- `MainShell` already owns the persistent bottom navigation inside its own bottom `SafeArea`.
- `AppLayout` explicitly documents that child screens must not duplicate shell/system bottom clearance.
- The duplicate bottom inset is materially larger on iOS and explains the platform-specific loss of Track viewport height.
- Track now preserves top/side safe-area protection while delegating bottom clearance to the shell with `bottom: false`.
- No Flow card geometry, persistence behavior, Android-specific padding, or save semantics were changed.
- Physical iPhone recheck is required before UX2-F08 closure.


##### UX2-F08 physical recheck — SafeArea fix insufficient
- Physical iPhone release build successfully installed and launched.
- Initial Track -> Flow viewport still clips the bottom of the `Very Heavy` card.
- Scrolling reveals the complete card and following insight content.
- Therefore the previous duplicate-bottom-SafeArea correction was valid but insufficient to close UX2-F08.
- Current physical screenshot shows the large manual `Save Changes` action is not present, so that action is not the remaining cause of initial `Very Heavy` clipping.
- No arbitrary card/font/padding reduction is authorized.
- Next audit must calculate the exact vertical budget from authoritative Flow card geometry, Track header/selector spacing, shell bottom navigation reservation, and platform typography.


##### UX2-F08 selected-option visibility implementation
- Previous mutation attempt stopped safely because the audited option hierarchy
  differed from the expected wrapper shape; no partial source mutation occurred.
- Current authoritative hierarchy is preserved:
  `Expanded -> Semantics -> GestureDetector -> Flow card`.
- A stable `GlobalKey` is attached directly to each existing `Semantics`
  option container; no duplicate/wrapper implementation was introduced.
- `FlowIntensityPicker` schedules selected-option visibility after initial
  layout and whenever `selectedIntensity` changes, including async-restored data.
- `Scrollable.ensureVisible` uses `keepVisibleAtEnd`; therefore already-visible
  cards should not be moved unnecessarily.
- No card size, typography, grid spacing, persistence semantics or platform
  hard-coded dimension was changed.
- Physical iPhone + Android release verification remains required.


##### UX2-F08 selected-card auto-scroll rollback
- Physical iPhone evidence rejected automatic selected-card scrolling.
- The implementation was completely removed rather than tuned.
- Flow option selection retains its existing semantic/test identity.
- UX2-F08 now returns to layout-budget correction.
- Approved target preserves the natural top position of the Flow grid and exposes
  the entire third row without forced scrolling.
- Standalone `Flow` heading remains the primary candidate for reclaimed vertical
  space, pending exact source typography and spacing measurements.


##### UX2-F08 Android-reference parity audit
- Physical Android evidence establishes the approved Track/Flow reference:
  - standalone `Flow` heading remains visible;
  - all six Flow intensity cards fit naturally;
  - `Very Heavy` is fully visible;
  - unsaved state can additionally show the manual Save Changes action;
  - no forced selected-card scrolling is required.
- Therefore hiding the Flow title is not yet authorized.
- The previous iOS-specific attempts treated symptoms rather than proving why
  iOS consumes more vertical space.
- Current audit compares exact Android/iOS typography tokens, date-header
  geometry, selector geometry, Track outer spacing, Flow card intrinsic
  geometry, Save Changes footprint and shell navigation reservation.
- Goal: reproduce the proven Android density on iOS at the highest shared or
  platform-specific authoritative owner without shrinking arbitrary controls.
- No estimated dimensions are authorized.


##### UX2-F08 exact method-owned Track typography parity
- Earlier mutation stopped safely because visible label `Flow` also occurs in
  `_buildTabBar`, making label-based ownership detection ambiguous.
- Exact source audit proved five authoritative section-title owners:
  `_buildFlowTab`, `_buildSymptomsTab`, `_buildMoodEnergyTab`,
  `_buildPainTab`, `_buildNotesTab`.
- `_buildCustomAppBar` owns the Track date `titleMedium`.
- Centralization now resolves and mutates those exact Dart methods rather than
  searching by UI label.
- Track section headings use the Android-reference 18px value.
- Track date title uses the Android-reference 14px value.
- Global iOS typography remains untouched.
- Physical verification is required before closure.


##### UX2-F08 single authoritative Flow insight owner
- Source audit proved duplicate selected-Flow insight presentation.
- `FlowIntensityPicker` already owns the localized AI Health Insights panel and
  selected Flow context.
- `TrackingScreen._buildFlowTab` duplicated the same concept with a second
  hard-coded insight and a dedicated 24px separator.
- Removed the Track-level duplicate presentation and retired `_getFlowInsight`.
- Flow cards, picker geometry, navigation, global typography and scrolling
  behavior remain unchanged.
- Physical iPhone and Android verification remains required before closure.

### Repository-native AI handoff

Status: ACTIVE / AUTHORITATIVE PROCESS

Root `AGENTS.md` is the permanent AI engineering entrypoint.

A new AI session should require only the canonical repository path.

Required continuation:
1. read `AGENTS.md`;
2. read `docs/mission_log.md`;
3. inspect branch, status, staged diff, and worktree diff;
4. continue the highest-priority ACTIVE mission from verified evidence;
5. update this mission log after every material verified change.

`docs/mission_log.md` remains the single authoritative detailed mission,
evidence, blocker, rollback, decision, and release-history ledger.

Do not create parallel mission logs or duplicate handoff documents.

Current UX2-F08 remains ACTIVE:
- six-card iPhone responsive layout physically working;
- AI Health Insights preserved;
- canonical contextual feedback requires Android/iPhone parity;
- bulb presentation + original product wording are authoritative;
- selected-state geometry/alignment defect remains unresolved;
- Android and iPhone physical verification are both required before closure.

### Canonical branch and clean-repository discipline

Status: ACTIVE / PERMANENT PROCESS

- All engineering continues on `release/central-integration-20260720`.
- No new/switch branches unless the user explicitly instructs it.
- Existing authoritative files are updated in place.
- Repository documentation must remain minimal and centralized.
- `AGENTS.md` is the single AI entrypoint.
- `docs/mission_log.md` is the single detailed mission/release ledger.
- No parallel mission, handoff, or release-history documents.
- The AI provides executable commands; the user is not expected to manually
  edit project files.

#### UX2-F08 physical cross-platform alignment evidence — 2026-09-16

Status: ACTIVE — PHYSICAL DEFECT NOT CLOSED

Verified physical findings:
- six Flow cards remain required in a 2-column × 3-row composition;
- rectangular cards are acceptable and preferred over distorting content;
- whole-grid Saved/Unsaved responsive sizing is useful and must be preserved;
- `None` is the exceptional state:
  - default/Saved `None` leaves the rendered grid visibly left-biased;
  - selecting `None` and entering Unsaved state shrinks the grid but retains the left bias;
  - selecting other Flow levels visually recenters the grid;
- the defect reproduces on iOS and Android, therefore it is a shared Flow picker/grid issue rather than a platform-only theme issue;
- do not redesign all six cards again until live rendered grid coordinates prove the responsible owner;
- long-press Flow medical information is useful and must remain;
- Heavy / Very Heavy Monitor indicators must remain inside their cards;
- AI Health Insights and green contextual feedback must remain available.

Required next evidence:
- physical/runtime measurement of whole-grid x/y/width/height and FittedBox/render transform for every selected intensity;
- compare `None` against Spotting, Light, Normal, Heavy and Very Heavy;
- only mutate after the exact selection-dependent alignment owner is proven.

#### Android advertising regression — 2026-09-16

Status: ACTIVE P0 — PHYSICAL REGRESSION

Verified user report:
- Android ads that previously displayed are no longer visible;
- source/contracts alone are insufficient for closure;
- keep MON12-AD1 / MON12-AD2 active until Android runtime evidence proves consent, premium suppression, banner request, load result and presentation state on eligible routes such as Home / Insights.

#### Calendar Android bottom dead-space backlog — 2026-09-16

Status: DEFERRED UNTIL CURRENT RELEASE BLOCKERS ARE STABLE

Physical finding:
- Calendar shows excessive unused vertical space after the `Current Cycle / No active cycle` section and before the persistent bottom navigation area;
- future UX pass should compact this region without overlapping the bottom navigation or harming scroll behavior.

### MON12-BILL1 — Google Play Billing deprecation

**Status:** CURRENT RELEASE ARTIFACT VERIFIED COMPLIANT — PLAY CONSOLE DEPLOYMENT PENDING

- Google Play Console warned that the currently published Flow Ai artifact uses a Google Play Billing version requiring remediation by 1 November 2026.
- Current release dependency resolution proves `com.android.billingclient:billing:8.0.0` through `in_app_purchase_android`.
- No explicit Billing Library 0–7 override was found in the audited Android/pubspec dependency surfaces.
- Current production release AAB builds successfully and its archive integrity is valid.
- Monetization/purchase/subscription/receipt regression tests pass.
- Flutter analyzer and `git diff --check` are green.
- Staged index integrity remained unchanged throughout verification.
- Source/release-artifact side is compliant. Final closure requires uploading the verified current AAB to the appropriate Google Play track and confirming the Play Console warning clears for the new artifact.

### MON12-AD6 — Android ad startup delay

**Status:** PHYSICAL FUNCTIONAL GATE PASSED — EXACT TIMING METRIC OPTIONAL/FOLLOW-UP

- Earlier Android runtime evidence isolated the historical ad delay to an approximately 20-second UMP consent wait before ad eligibility became true.
- A returning-user UMP fast path was implemented so previous-session valid consent can be checked immediately after starting the UMP refresh.
- First-time/unknown consent remains fail-closed.
- UMP refresh, privacy options, Premium suppression, route restrictions, banner-generation ownership, and stale-load protection remain intact.
- Targeted consent/ad-suppression/banner/Premium-ad-disposal contracts passed.
- Android physical verification now confirms banners display normally on the intended Home and Insights routes.
- Latest regression runtime showed no app crash signal.
- Flutter analyzer and `git diff --check` are green.
- Staged tree/index integrity remained unchanged.
- Functional release blocker is cleared. Exact millisecond startup telemetry is not required to keep the release blocked and can be folded into persistent runtime observability work under MON12-OBS1A.

### UX2-F08 — Flow intensity cards

**Status:** CLOSED — PHYSICAL iPHONE + ANDROID PARITY VERIFIED

- Approved six-card Flow layout remains intact: 2 columns × 3 rows.
- Whole-grid responsive scaling is preserved; per-card FittedBox scaling remains rejected.
- Selection geometry tests remain at 0.000 movement for all intensities.
- Heavy / Very Heavy badges remain inside their cards.
- AI Health Insights, contextual feedback, subtitles, and long-press medical information remain intact.
- The remaining internal alignment issue affecting the None card was physically verified fixed on iPhone.
- The same corrected layout was physically verified on Android with no parity regression.
- Responsive and selection-geometry tests passed.
- Flutter analyzer and git diff checks remained green.
- Staged index integrity remained unchanged.

### UX2-F08 — Flow card alignment closure update — 2026-09-17

Status: PHYSICAL iPHONE VERIFIED | ANDROID PARITY PENDING

Root cause:
- the defect was not individual `None` card geometry;
- when `FlowIntensity.none` was selected, the picker lacked a guaranteed full-width descendant because contextual/insight content is conditionally absent;
- the surrounding Track column uses start alignment;
- this allowed the Flow picker / scaled grid to remain narrower and appear left-biased;
- non-None states gained a full-width descendant from contextual content and therefore appeared centered.

Production fix:
- centralized width ownership at `FlowIntensityPicker`;
- picker children now stretch to the available horizontal width;
- no per-card scaling was introduced;
- existing whole-grid `FittedBox(scaleDown)` behavior remains;
- Saved/Unsaved responsive whole-grid shrinking remains;
- all six Flow cards remain;
- Heavy / Very Heavy Monitor badges remain;
- long-press medical information remains;
- AI Health Insights remains;
- contextual feedback remains.

Verification state:
- source owner verified;
- existing responsive/selection/contextual tests previously green;
- analyzer previously green;
- iPhone physical visual result accepted;
- Android physical parity remains the final UX2-F08 closure gate.

Next UX2-F08 gate:
- run release build on Samsung `RF8NA1QJR7H`;
- verify Saved + None centered;
- verify Unsaved + None shrinks while remaining centered;
- verify Spotting / Very Heavy remain centered;
- if parity passes, mark UX2-F08 PHYSICAL ANDROID VERIFIED / CLOSED.

### Next active mission after UX2-F08

MON12-AD6 — Android Ad Startup Delay

Status: ACTIVE

Existing physical telemetry already proved:
- consent begins immediately during ad initialization;
- `requestConsentInfoUpdate()` consumes approximately 20 seconds;
- Mobile Ads SDK initialization itself takes only approximately 0.30 seconds;
- banner loading begins successfully once `canRequestAds` becomes true;
- Android ads physically display;
- remaining defect is startup latency, not missing ad rendering.

Next gate:
- deep-audit current UMP consent owner and timeout behavior;
- determine why the consent-info request waits approximately 20 seconds;
- preserve consent correctness and legal/privacy behavior;
- do not shorten/bypass consent blindly;
- instrument exact UMP callback/timeout/error timing if source evidence alone is insufficient.

### MON12-OBS1A — Persistent Runtime Telemetry

Status: ACTIVE / AFTER MON12-AD6

Continue centralized, privacy-safe runtime observability:
- navigation;
- user actions;
- ads/consent;
- entitlement transitions;
- release-critical errors;
- persistent on-device sink rather than relying on release `developer.log`.

### Calendar Android dead-space

Status: DEFERRED

Keep tracked separately:
- excessive unused vertical space after `No active cycle`;
- before persistent bottom navigation;
- fix only after current release blockers are stable.

### Release state synchronization — 2026-09-17

#### UX2-F08 — Flow intensity cards

Status: CLOSED — PHYSICAL iPHONE + ANDROID PARITY VERIFIED

Verified:
- six-card 2×3 Flow layout preserved;
- None-state alignment corrected;
- iPhone physical verification passed;
- Android physical parity passed;
- selection geometry remains stable;
- responsive test matrix passed;
- Heavy / Very Heavy badges remain contained;
- AI Health Insights remains;
- contextual feedback remains;
- long-press information remains;
- whole-grid responsive scaling remains;
- no known remaining UX2-F08 blocker.

Do not return UX2-F08 to the active blocker list unless a new reproducible regression is observed.

#### MON12-AD6 — Android ad startup delay

Status: CLOSED — PHYSICAL FUNCTIONAL GATE PASSED

Verified:
- UMP returning-user fast path implemented;
- first-time / unknown consent remains fail-closed;
- UMP refresh and privacy handling remain intact;
- targeted consent/ad suppression/banner/Premium-ad contracts passed;
- ads physically display normally on Home and Insights;
- analyzer remained green;
- staged index remained unchanged.

Exact millisecond observability belongs to runtime telemetry work and does not keep AD6 open.

Do not return MON12-AD6 to the active blocker list unless a new reproducible ad startup/rendering regression is observed.

#### MON12-BILL1 — Google Play Billing

Status: 95% — PLAY CONSOLE DEPLOYMENT ONLY

Verified:
- releaseRuntimeClasspath resolves `com.android.billingclient:billing:8.0.0`;
- production AAB builds successfully;
- AAB archive integrity passed;
- no explicit Billing 0–7 override found;
- 26 monetization/purchase regression test files passed;
- analyzer passed;
- staged index unchanged.

Remaining gate:
- upload the verified compliant AAB to the appropriate Google Play track;
- confirm Play Console warning clears for the new artifact.

#### MON12-OBS1A — Persistent runtime navigation telemetry

Status: ACTIVE — CROSS-PLATFORM PHYSICAL CLOSURE IN PROGRESS

Verified:
- router delegate is the authoritative navigation signal;
- ShellRoute `context.go()` transitions are observable through router delegate;
- path-only telemetry ownership preserved;
- ProductionAnalyticsService remains the single analytics authority;
- persistent diagnostics are default OFF and validation-build gated;
- persistent JSONL sink implemented;
- privacy contract passes;
- navigation contract passes;
- analyzer passes;
- staged index remains unchanged;
- iOS appDataContainer extraction capability proven;
- Android app-specific external storage is ADB-readable.

Current gate:
- complete Android physical persistent telemetry capture;
- verify fresh route events;
- verify path-only schema;
- verify no PII/query/token fields;
- verify timestamps belong to the exact run;
- then close OBS1A.

#### MON12-OBS1B — User-action telemetry

Status: QUEUED

After OBS1A closes, extend the same centralized, privacy-safe observability architecture to:
- user actions;
- ad lifecycle;
- consent lifecycle;
- entitlement transitions;
- release-critical errors.

Do not create a parallel telemetry owner.

#### Calendar Android dead-space

Status: DEFERRED

Known issue:
- excess unused vertical space after `No active cycle`;
- before persistent bottom navigation.

Handle as a separate UI mission after current release-critical telemetry and monetization gates.

### MON13/14-C5 — Premium scroll/motion parity

Progress: 85%

- Premium uses one shared CustomScrollView with BouncingScrollPhysics and AlwaysScrollableScrollPhysics.
- Physical evidence showed the back control can disappear after the page is normally scrolled.
- Source audit proves the back control currently belongs to the scroll content, so its disappearance is not sufficient evidence of failed overscroll spring-back.
- Temporary physical scroll metrics instrumentation records pixels, minScrollExtent, maxScrollExtent, and outOfRange.
- C5 requires physical proof that true overscroll returns inside the valid scroll extent after release on Android and iPhone.
- Normal user scrolling must remain available on viewports where content exceeds the visible height.
- Floating navigation independence is tracked separately in C9.

### MON13/14-C9 — Floating navigation control

Progress: 0%

- Premium back navigation currently lives inside the scrolling column.
- Future work must move navigation outside scroll ownership so it remains independently visible.
- Before implementation, audit the existing Health / Daily Feelings / Add Symptoms interaction and visual treatment.
- Reuse or centralize the established translucent/floating navigation technology rather than creating a Premium-only duplicate.
- Must respect SafeArea, accessibility hit area, dark/light themes, Android/iPhone viewport differences, and centralized adaptive ownership.
- Implement only after the current Premium layout and scroll missions are closed.

### MON13/14-C4 — Premium responsive layout

Progress: 97%

Latest evidence:
- Physical Android free-state paywall remained vertically unbalanced even though plan-card and catalog spacing had already been centralized.
- Deep source audit confirmed remaining fixed/free-state pressure came from surrounding header rhythm, CTA geometry and final footer breathing room.
- Free-state vertical density now has one centralized viewport-derived owner.
- Active Premium layout is intentionally unchanged.
- No Android/iOS geometry fork was introduced.
- Premium regression suite and analyzer must remain green.
- Remaining proof: fresh physical Android free-state default screenshot with complete legal/footer content visible.

### MON13/14-C8 — Premium UI truth

Progress: 95%

Latest evidence:
- Verified provider expiry continues through backend/client without synthetic extension.
- Same-calendar-day verified expiry displays both date and local time.
- This is particularly important for accelerated sandbox subscriptions.
- Remaining proof: physical iPhone active-state expiry display and account-isolation closure after C7.

#### Measured Premium viewport fold
- Physical iPhone runtime measurement established viewport=763.00 logical px, restoreBottom=759.78 and legalTop=783.78 at initial offset 0.00.
- The legal footer therefore entered the natural first viewport by 26.22 logical px.
- No fixed correction was introduced.
- Premium content through Restore remains in the primary content sliver.
- SliverFillRemaining now consumes only the actual unused viewport extent.
- Legal copy lives in a following sliver and therefore begins below the natural first viewport when space permits.
- Existing Premium feature navigation, subscription options key and Scrollable.ensureVisible behavior remain unchanged.
- Temporary geometry instrumentation was removed after measurement.

#### Premium Active measured viewport alignment
- Approved physical target screenshot measured at 591x1280.
- Active composition target uses the entire badge-through-Restore surface as one layout unit.
- Approximate measured remaining-space distribution is 70% above / 30% below the active unit.
- Equivalent normalized vertical alignment is Alignment.y = +0.40.
- The active unit is positioned through viewport-derived SliverFillRemaining rather than independent fixed spacing adjustments.
- Restore-to-legal spacing remains the previously approved natural spacing and is not enlarged.
- Floating navigation remains independent of scrolling.
- No Android/iOS layout fork is introduced.

#### Premium Active measured positioning correction
- Previous SliverFillRemaining/Alignment approach was rejected by physical evidence because it enlarged the visual void after Restore Purchases.
- Approved Restore-to-legal spacing is locked at its original natural layout rhythm.
- iPhone runtime measurement proved safeViewportBottom=810.00, legalTop=783.78 at offset 0.00.
- Required whole-composition displacement is therefore 26.22 logical px.
- Correction is applied to the whole Premium Active composition rather than to the Restore/legal relationship.
- The position owner scales from the measured 26.22/763.00 usable-viewport ratio.
- No Android/iOS branch is introduced.

#### iOS Premium Active physical layout approval
- Default physical iPhone state now shows the complete Premium Active composition through Restore Purchases.
- Legal copy remains below the first viewport and appears with the approved natural spacing after a small scroll.
- No artificial Restore-to-legal gap is used.
- The floating back control remains visible independently of scroll content.
- The measured whole-composition positioning is approved for iOS physical layout.

#### Premium Active two-device measured calibration
- Android physical Premium Active measurement: viewport=867.05, badgeTop=69.80, restoreBottom=785.42, legalTop=809.18, fold=899.43.
- Existing Restore-to-legal spacing=23.76 and is intentionally unchanged.
- Required Android whole-composition downward correction=90.25 logical px.
- Corrected Android active top offset≈120.04.
- Existing approved iOS reference remains viewport=763.00, offset=26.22.
- Active layout owner now interpolates between the two measured physical viewport references.
- No platform-specific Android/iOS geometry branch is used.

#### MON13/14-C4 — constraint-driven Premium vertical layout
- Removed `_premiumActiveMeasuredTopOffset` and the physical-device magic calibration values `26.22` / `120.04`.
- Premium first-view content is now owned by `SliverFillRemaining(hasScrollBody: false)`.
- Surplus viewport height is handled by layout constraints instead of Android/iOS-specific or device-specific top translation.
- Main Premium content centers only when the viewport has genuine surplus height.
- Legal copy remains a separate subsequent sliver, preserving the natural Restore-to-legal relationship and scroll behavior.
- Floating Back control remains outside the scroll content.
- Physical Android and iPhone verification remains required before C4 closure.

#### MON13/14-C4 — Premium natural-flow correction
- Removed SliverFillRemaining from the Premium first-view composition.
- Removed MainAxisAlignment.center from the Premium root content column.
- Root cause: viewport filling created artificial empty space after Restore Purchases because legal content is a subsequent sliver.
- Premium content now uses normal SliverToBoxAdapter document flow with a 16 logical-pixel design top inset.
- Restore Purchases is followed by legal content according to natural content geometry rather than artificial viewport remainder.
- No Android/iOS geometry branch and no physical-device magic offsets remain.
- Physical Android + iPhone verification is required before C4 closure.

#### MON13/14-C4 — iOS Premium layout acceptance lock
- iOS Premium Active physical layout accepted by user on 2026-09-19.
- Accepted screenshot reference: 591x1280.
- Accepted geometry includes badge/header, feature cards, subscription card, Manage Subscription, Restore Purchases, legal text, and floating Back control.
- iOS vertical geometry is frozen for this release.
- Remaining C4 work is Android-only in effect, but must be implemented through centralized viewport/constraint ownership rather than arbitrary platform-specific geometry branches.
- Any subsequent Premium layout mutation must preserve the accepted iOS composition within physical-regression tolerance.

#### MON13/14-C4 — measured tall-viewport vertical redistribution
- Android Action 34 physical geometry: usable=867.05dp, topFree=54.00dp, bottomRemaining=14.04dp, Restore-to-legal=23.76dp.
- Source audit proved Premium had two adaptive post-action root gaps plus one final fixed 8dp gap.
- On tall usable viewports, the two adaptive post-action gaps are transferred exactly to the root top inset instead of increasing total document height.
- Android measured expected transfer≈15.76dp: top free≈69.76dp, Restore-to-legal≈8dp, bottom remaining≈14.04dp.
- Accepted iOS usable height=763dp produces transfer factor 0; accepted iOS geometry remains unchanged.
- No Platform.isAndroid / Platform.isIOS geometry branch introduced.

#### MON13/14-C4 — CLOSED — Premium responsive layout
- Status: 100%.
- iOS Premium Active physical layout accepted and locked by user.
- Android final physical geometry proved:
  - usable fold=899.43dp
  - badgeTop=102.14dp
  - Restore-to-legal=8.00dp
  - legalBottom=885.39dp
  - bottomRemaining=14.04dp
- Android Premium Active and Free states fit the default viewport without artificial filler.
- Removed temporary physical-geometry instrumentation after proof.
- Preserved `_subscriptionOptionsKey` and feature-tap subscription guidance contract.
- Free subtitle finalized as `Access unlimited premium features.`
- Premium feature interaction contract: 3/3 passed.
- Full Premium regression: 88/88 passed.
- Flutter analyzer: 0 issues.
- No Android/iOS geometry branch introduced.
- Premium geometry is frozen for this release unless a reproducible regression is proven.

#### MON13/14-C4 — CLOSED — Premium responsive layout
- Status: 100%.
- iOS Premium Active physical layout accepted and locked by user.
- Android final physical geometry proved:
  - usable fold=899.43dp
  - badgeTop=102.14dp
  - Restore-to-legal=8.00dp
  - legalBottom=885.39dp
  - bottomRemaining=14.04dp
- Android Premium Active and Free states fit the default viewport without artificial filler.
- Removed temporary physical-geometry instrumentation after proof.
- Preserved `_subscriptionOptionsKey` and feature-tap subscription guidance contract.
- Free subtitle finalized as `Access unlimited premium features.`
- Premium feature interaction contract: 3/3 passed.
- Full Premium regression: 88/88 passed.
- Flutter analyzer: 0 issues.
- No Android/iOS geometry branch introduced.
- Premium geometry is frozen for this release unless a reproducible regression is proven.

#### MON13/14-C5 — CLOSED — Premium scroll/spring parity
- Status: 100%.
- Android physical instrumentation previously proved overscroll can exceed the valid extent and springs back inside the valid scroll range after release.
- Final physical Android and iPhone screenshots proved Premium content scrolls normally in both directions.
- No temporary scroll instrumentation remains.
- Premium scroll behavior is accepted for this release unless a reproducible regression appears.

#### MON13/14-C9 — CLOSED — Floating navigation control
- Status: 100%.
- Physical Android proof: Premium content was visibly scrolled while the top-right Back control remained fixed.
- Physical iPhone proof: Premium badge/header moved partially off-screen during scrolling while the Back control remained fixed in its viewport position.
- Back control is therefore independently owned outside the scroll content.
- C9 is closed for this release unless a reproducible regression appears.

#### MON13/14-C7 — local deterministic receipt ownership implementation
- Added SHA-256 deterministic ownership keys from platform + originalTransactionId.
- Added `premiumReceiptOwners` as the authoritative receipt-chain owner collection.
- Ownership uses existing receipt-service `projectId()` resolution.
- Added migration-on-read against historical subscription entitlement documents.
- Zero historical owners: current verified UID may claim.
- One historical owner: historical UID is canonical.
- Multiple historical owners: fail closed with HTTP 409; no ownership guess.
- Atomic create-only claim prevents concurrent accounts from both acquiring one purchase chain.
- Create races re-read the authoritative owner before entitlement persistence.
- Receipt ownership is enforced before `persistValidatedEntitlement`.
- No Firebase Admin SDK introduced.
- Existing legacy entitlements remain untouched pending explicit legacy-conflict resolution.

### C7 Account ownership — executable behavioral proof

Verified:
- Receipt-service behavioral matrix: 14/14 PASS.
- All 9 required ownership behaviors execute successfully.
- `npm run verify`: PASS.
- ESLint: PASS.
- TypeScript typecheck: PASS.
- Receipt-service build: PASS.
- Runtime smoke: PASS (`SMOKE=PASS`).
- Ownership remains enforced before entitlement persistence.
- HEAD/index unchanged during verification.

Remaining gate:
- Production deployment.
- Real two-account receipt-isolation proof.
- Confirm conflicting account receives HTTP 409.
- Confirm rejected account receives no entitlement write.

### C7 Account ownership — physical cross-account closure

Verified on physical Android:
- First legitimate authenticated Google restore created exactly one `premiumReceiptOwners` document.
- Canonical owner UID suffix: `yyF6h2`.
- Ownership source: `first_verified_claim`.
- Different Flow Ai account UID suffix: `dKq8P2`.
- Same Google Play receipt restored from the different Flow Ai account reached the C7 canary.
- Receipt validation request returned HTTP 409.
- Ownership document count remained exactly 1.
- Canonical owner remained `yyF6h2`.
- Different account remained non-Premium (`Unlock Premium`).
- No cross-account entitlement grant occurred.
- C7 account ownership gate: PASS / CLOSED.

### C8 Premium UI truth — physical expiry closure

Verified on physical Android:
- Valid cancelled subscription remained Premium until its authoritative expiry time.
- Premium Active state correctly displayed current plan, expiry, Manage Subscription, and Restore Purchases while entitlement remained valid.
- After expiry and app relaunch, UI transitioned to Unlock Premium.
- Premium Active state and active subscription card were removed.
- Expiry scheduler implementation passed targeted tests, full Premium suite, and analyzer.
- C8 Premium UI truth gate: PASS / CLOSED.

### C7 Account ownership — production rollout closure

Verified:
- C7 revision `flow-ai-receipt-service-v2-00013-bfw` passed staged production rollout.
- 10% canary monitoring completed with health 200, 0 errors and 0 HTTP 5xx.
- Production traffic advanced to 100% on `00013-bfw`.
- Final health returned HTTP 200.
- Final production telemetry returned 0 errors and 0 HTTP 5xx.
- Cross-account receipt replay rejection had already passed physically with HTTP 409 and unchanged canonical ownership.
- C7 production gate: PASS / CLOSED.

### MON13 Android purchase/restore — physical restore evidence

Verified on physical Android:
- Google Play restore reached authenticated receipt validation.
- Backend returned HTTP 200 after Firestore collection-group index repair.
- `premiumReceiptOwners` migrated from 0 to 1 canonical Android owner.
- Premium Active, current subscription and Manage Subscription rendered correctly.
- Cross-account restore of the same Google Play receipt returned HTTP 409 and did not grant Premium.
- Paid-through cancellation remained Premium until expiry.
- Post-expiry UI returned to Unlock Premium.
- Physical restore path: PASS.
- Fresh physical purchase path remains to be evaluated separately; do not infer closure from restore evidence.

### FUTURE — Premium legal/renewal disclosure cleanup

- Replace the always-visible `Subscription automatically renews unless canceled. Terms and Privacy Policy apply.` block with a compact disclosure control.
- Default state: collapsed.
- Use a simple downward chevron `∨` / platform-appropriate chevron, not an arrow-with-stem.
- Tap expands renewal/legal text; tap again collapses it.
- Preserve accessibility, legal visibility, dark/light parity, Android/iPhone parity, and safe-area behavior.
- Do not alter current monetization truth or release blockers while implementing this future UI refinement.

### MON14 iPhone Purchase/Restore — physical restore evidence

- Physical device: iPhone 12 Pro, release build only.
- Installed bundle: `com.flowai.health`.
- Current authenticated Flow Ai UID suffix: `IBvNE2`.
- Historical Apple receipt conflict was traced to the same Apple purchase chain having been observed while different Flow Ai accounts were used on the iPhone (Apple-login and Gmail-login accounts).
- The physical iPhone app-container evidence proved the current authenticated UID matched historical owner suffix `IBvNE2`.
- A single guarded canonical ownership adjudication was created for that Apple receipt chain with owner UID suffix `IBvNE2`.
- Subsequent physical `Restore Purchases` generated Apple receipt-service responses:
  - HTTP 200
  - HTTP 200
  - HTTP 200
- Canonical receipt owner remained UID suffix `IBvNE2`.
- No iOS ownership reassignment occurred during restore.
- Post-restore backend failures: `0`.
- HEAD and staged index remained unchanged.
- iPhone physical Restore Purchases path: PASS.
- Do not infer fresh-purchase closure from restore evidence; evaluate the remaining MON14 purchase gate independently.
- Account-switch requirement: the same Apple receipt must remain bound to its canonical Flow Ai owner and fail closed when another unlinked Flow Ai account attempts to claim it.

### MON14 iPhone Purchase/Restore — physical purchase closure

- Physical device: iPhone 12 Pro.
- Verification used a Release build only.
- Sandbox Apple Account was explicitly configured in iOS Developer settings.
- Fresh Monthly Premium purchase completed on the physical iPhone.
- Flow Ai transitioned to `Premium Active`.
- UI showed `Monthly Premium` with authoritative expiry.
- Apple receipt-service request returned HTTP 200.
- Receipt owner remained canonical Flow Ai UID suffix `IBvNE2`.
- No Apple receipt validation errors were recorded.
- Restore Purchases had already independently passed with repeated HTTP 200 responses and zero backend failures.
- Therefore physical iPhone fresh purchase gate: PASS.
- Therefore physical iPhone restore gate: PASS.
- Manage Subscription behavior for development-installed Sandbox builds is audited separately and must not be confused with production App Store subscription management behavior.

### MON13 Android Purchase/Restore — physical production closure

- Physical Android device: Samsung SM-N770F.
- Release build only.
- Google Play license-test purchase environment explicitly verified:
  - `Test card, always approves`
  - `This is a test subscription`
  - `You will not be charged`
- Fresh Monthly Premium purchase completed successfully.
- Flow Ai transitioned to `Premium Active`.
- New Google receipt chain was created without overwriting existing ownership.
- Fresh purchase receipt validation returned HTTP 200.
- Final Android Release APK was rebuilt with canonical production receipt-service URL:
  `https://flow-ai-receipt-service-v2-ylrxu2v7qq-uc.a.run.app`
- Binary inspection proved:
  - production endpoint present
  - c7-canary endpoint absent
- Signing certificate matched the previously installed production app.
- Verified production Release APK installed successfully.
- Physical Restore Purchases against canonical production endpoint returned HTTP 200.
- Flow Ai displayed `Subscription verified — Premium is active.`
- Post-restore backend failures: 0.
- HEAD and staged index remained unchanged.
- MON13 fresh purchase gate: PASS.
- MON13 restore gate: PASS.
- MON13 production-artifact endpoint gate: PASS.
- MON13: CLOSED.

### MON12-OBS1A — physical Android telemetry closure

- Physical device: Samsung SM-N770F.
- Verification used a Release build only.
- Existing authoritative runtime telemetry pipeline was used:
  `RuntimeNavigationTelemetry -> ProductionAnalyticsService.recordNavigationDiagnostic`.
- Validation switch: `FLOW_AI_RUNTIME_DIAGNOSTICS=true`.
- Persistent sink: `flow_runtime_navigation.jsonl` in Android app-specific external storage.
- Fresh physical persistent-navigation events were captured.
- Multiple distinct physical routes and transitions were observed.
- Telemetry schema remained limited to timestamp, navigation type, route path, and optional previous path.
- No query parameters or fragments were persisted.
- No user identity, authentication token, receipt, purchase token, email, phone, address, password, or session field was persisted.
- Existing OBS1A contracts passed.
- Normal production-wired APK was restored after validation.
- HEAD and staged index remained unchanged.
- MON12-OBS1A: CLOSED.

### MON12-BILL1 — final AAB forensic preflight

- Final production AAB: `build/app/outputs/bundle/release/app-release.aab`.
- Package: `com.flowai.app`.
- Version: `2.2.4`.
- Version code: `1783342117`.
- Resolved Google Play Billing dependency: `com.android.billingclient:billing:8.0.0`.
- AAB signature verification: PASS.
- Canonical production receipt-service endpoint embedded: PASS.
- `c7-canary` endpoint absent from the final AAB.
- Deep `localhost` investigation found no production-reachable Flow Ai Dart source hit.
- High-risk release contamination gate: PASS.
- Final AAB SHA-256:
  `9795d8b076460881b548236fab9cfcb26fbb56cc57eba97f5baa3a160db3025c`.
- AAB immutability gate: PASS.
- No production patch was justified by the generic `localhost` binary string.
- Remaining MON12-BILL1 gate: Play Console upload/deployment confirmation.

### FUTURE — Premium pinned active header

- Preserve the current Premium Active medal/logo and main `Premium Active` title as the stable visual identity.
- On scroll, keep the medal/logo and main title pinned while content beginning with `Your Premium subscription is active.` scrolls beneath the pinned header.
- Implement through the authoritative Premium screen layout using a proper pinned/sliver header architecture rather than per-device pixel offsets.
- Header behavior must respect Android/iPhone safe areas, dynamic text sizing, compact screens, dark/light parity, accessibility and existing C4/C5/C9 geometry contracts.
- Scrolling must remain smooth and preserve the existing spring/scroll behavior.
- The pinned header must not cover plan state, restore results, entitlement truth, or purchase-management controls.
- Validate on both physical Android and iPhone before release.
- This is future UX work and must not interrupt the current MON12/MON15 release gates.
