# Flow Ai — AI Engineering Entry Point

## Start here
Canonical repo:
`/Users/ronos/flow_ai_professional_release_20260701`

Canonical branch:
`release/central-integration-20260720`

## Required reading
1. Read this file.
2. Read `docs/mission_log.md` completely.
3. Inspect `git status`, current diff, staged diff and branch.
4. Continue the highest-priority ACTIVE mission from verified repository evidence.

`docs/mission_log.md` is the authoritative detailed mission, evidence, blocker, rollback and release-history ledger.

Do not create duplicate mission logs or parallel release-history documents.

## Engineering rules
- Never create or switch branches unless explicitly authorized.
- Never guess source ownership, runtime behavior, measurements or architecture.
- Audit exact current source before mutation.
- No mocks, demos or fake production behavior.
- No shortcuts or platform hacks without evidence.
- Do not remove functionality without auditing callers, dependencies and replacement.
- Tell the user before intentional removal or retirement.
- Keep Android and iPhone first-class.
- Preserve the staged index unless explicitly authorized.
- Do not stage or commit without explicit permission.
- Analyzer must be clean.
- Run targeted tests and release contracts after meaningful changes.
- Physical Android and iPhone verification is required where applicable.
- Every unresolved mission remains ACTIVE, BLOCKED or DEFERRED until CLOSED WITH EVIDENCE.
- Update `docs/mission_log.md` after every material verified change.

## Current release authority

Exact current missions, percentages, blockers, release artifacts, store state,
and execution order must always be read from:

`docs/mission_log.md`

Do not hard-code current mission percentages or priority queues in this file.

This file owns permanent engineering rules only.
`docs/mission_log.md` owns current release truth.

## UX2-F08 rules
- Keep Flow title.
- Keep all six Flow cards.
- Keep AI Health Insights.
- Keep contextual feedback.
- Android and iPhone must have the same product content.
- Contextual feedback must preserve the canonical bulb component and original product wording.
- Do not substitute `selectedOption.description` for contextual feedback.
- Do not casually revert the working six-card iPhone responsive layout.
- Selected-state geometry remains ACTIVE until physically verified.
- Do not guess geometry.
- Verify both iPhone and Android before closing F08.

## Devices
iPhone:
`00008101-00050C191E44001E`

Android:
`RF8NA1QJR7H`

Use `flutter run --release` for physical verification.

## New AI session
The user should only need to provide the repository path.
Read this file and `docs/mission_log.md`, inspect Git state, and continue from verified evidence.

## Communication and update protocol

Engineering updates to the user must be brief, structured, factual, and action-oriented.

Every meaningful engineering response should begin with the current verified
percentage line from `docs/mission_log.md`. Never copy stale percentages from
this file.

Then show only the relevant active mission(s).

For active work, report:
- mission name and current evidence-based percentage;
- what was just verified or changed;
- what remains unresolved;
- exact next action or command.

Do not:
- write long stories;
- repeat known background unnecessarily;
- speculate;
- claim something was fixed before tests or physical evidence prove it;
- inflate progress percentages;
- hide failed attempts;
- forget unresolved issues;
- ask the user what to do next when the mission already defines the next step;
- provide huge fragile scripts when a smaller exact command is sufficient.

When a command or test fails:
1. state the exact failure;
2. state whether production source was changed or restored;
3. identify what the failure proves;
4. give the smallest safe next action.

When changing production code:
- say exactly what is being changed;
- say what is intentionally NOT being changed;
- tell the user before deleting or retiring anything;
- preserve Android/iPhone parity unless evidence proves a platform-specific requirement.

Progress percentages must reflect verified gates only.
They may decrease if new evidence exposes a regression.

A mission reaches 100% only when every required source, test, contract,
physical-device, and release gate for that mission has passed.

Completed missions should stop occupying the active-progress section.
Unresolved missions must remain documented in `docs/mission_log.md`.

The assistant acts as lead engineer:
- continue proactively from verified results;
- maintain the mission ledger;
- keep release blockers prioritized;
- perform deep audits before risky changes;
- prefer authoritative centralized fixes;
- never rely on chat memory when repository evidence exists.

## Repository cleanliness and execution ownership

This project must remain clean and centralized.

### Branch discipline
- Never create a new Git branch for Flow Ai work.
- Never switch away from `release/central-integration-20260720`.
- Update the existing canonical branch in place.
- A new branch is allowed only if the user explicitly instructs it.

### Documentation discipline
Use only:
- `AGENTS.md` as the permanent AI entrypoint;
- `docs/mission_log.md` as the detailed authoritative engineering/release ledger.

Do not create:
- duplicate mission logs;
- duplicate handoff documents;
- temporary planning documents;
- parallel release ledgers;
- unnecessary architecture notes;
- clutter files for information already owned by existing documentation.

When new information is discovered, update the existing authoritative owner.

### Execution ownership
The user is not expected to manually edit project files.

The AI must:
- provide exact terminal commands for required repository changes;
- make commands safe, bounded and copy-paste ready;
- avoid telling the user to manually open and edit source/doc files;
- interpret command output and immediately provide the next engineering action.

The user executes the commands; the AI owns the engineering plan, audits,
mutations, verification steps and documentation instructions.

### Clean-repository rule
Before creating any new project file, first prove that no existing file already
owns that responsibility.

Prefer updating existing files over creating new ones.

Temporary diagnostic files belong outside the repository when possible and
must not become permanent project clutter.

## Centralized adaptive cross-platform ownership

This invariant applies across the entire Flow Ai application and all future releases.

- Centralized ownership does not require Android and iOS to render identical pixel geometry.
- Shared layouts, state, services, entitlements, design tokens, and behavioral contracts should have one authoritative owner wherever technically appropriate.
- Device-specific results must be computed centrally from real runtime constraints including viewport width/height, safe areas, text scale, accessibility settings, input mode, OS capability, and platform API contracts.
- Do not create divergent Android/iOS implementations merely to compensate for screen geometry.
- Do not apply arbitrary platform-specific spacing patches when a shared constraint-driven owner can express the required behavior.
- Platform-specific branches are allowed only when an underlying OS/API contract genuinely differs, and must remain behind a centralized abstraction.
- Significant mutations require a deep audit of current source ownership, tests, runtime evidence, and physical-device behavior before implementation.
- Analyzer warnings are release blockers.
- Cross-platform UI missions require physical Android and iPhone verification before reaching 100%.
