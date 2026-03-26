# MIRA AI Mission Plan

## Purpose
Build a premium, trustworthy, emotionally safe AI assistant for women's health inside Flow AI.
Mira must feel elegant, modern, stable, useful, and deeply aligned with the app's purpose:
cycle, period, ovulation, fertility, spotting, symptoms, and guidance.

---

## Working Rules

### Process rules
1. Always inspect root cause before any edit.
2. Never patch blindly.
3. One command at a time.
4. Bash commands only during implementation flow.
5. No mixing commands with explanatory notes inside the command block.
6. Keep responses short.
7. If something fails, stop and inspect before changing anything else.
8. Do not assume a fix without verifying the exact lines.
9. Prefer targeted edits over broad edits.
10. Re-run analyze/build after structural edits.
11. Commit checkpoints before risky UI rewrites.
12. Keep a stable fallback path.

### Build and debugging rules
1. Use `flutter analyze` before guessing.
2. Inspect exact line ranges before editing broken blocks.
3. If simulator build fails, inspect real root output first.
4. Distinguish Dart syntax errors from simulator/Xcode state issues.
5. Do not clean or undo unless inspection justifies it.
6. Preserve working state whenever possible.

### Product rules
1. Mira must be clearly a women-focused cycle/fertility/symptom assistant.
2. Suggestions must stay domain-specific.
3. Suggestions must not become generic health/science/technology prompts.
4. UX must feel premium and calm.
5. Avoid jarring controls, duplicate buttons, broken layers, or overlapping containers.
6. Keep the assistant friendly, gentle, and trustworthy.
7. The product should feel real, polished, and winning for women users.

---

## Current Agreed UI Direction

### Header
- Gradient glass-style header
- Premium AI identity
- Modern AI bubble/glass orb avatar
- Clear title: Mira AI Assistant
- Support subtitle/status line
- Fullscreen button optional
- Replace X close button with rounded chevron/down-collapse style button
- Collapse button should visually match the reference screenshot

### Card style
- Floating premium card
- Soft gradient
- Glass-like feel
- Rounded corners
- No heavy duplicate outer/inner chat box feel
- No ugly overlapping layers
- No broken shell/container stacking

### Suggestions
- Must remain visible after tapping a suggestion
- Manual collapse only
- No auto-hide after message send
- Horizontal single-line left-right scrolling row
- Around 10 suggestions
- Domain-specific only
- Clean chip sizing
- Presentable spacing
- No vertical multi-row clutter

### Input
- Input placeholder and wording should match Mira’s purpose:
  cycle, fertility, symptoms, period, ovulation, spotting
- No generic “health, science, technology, lifestyle” copy
- Input area should feel integrated with the card
- No overlap with surrounding content

---

## Functional Agreements

### Suggestions behavior
Suggestions must:
- persist after tap
- only collapse via manual chevron toggle
- stay horizontally scrollable
- remain relevant to cycle/fertility/symptoms

### Close/collapse behavior
- Chevron button replaces X
- Button must work reliably
- It should collapse/hide cleanly
- It should not break layout
- It should visually align with the reference screenshot

### Expansion state
- `_isExpanded` controls assistant visibility
- `_showQuickReplies` controls suggestions visibility only
- These states must not be wrongly coupled
- Sending a message must not hide suggestions unless user collapsed them manually

---

## Current Known Problems To Eliminate
1. Suggestions disappearing after tap
2. Wrong close button style
3. Avatar styling inconsistency
4. Overlap between chatbot and underlying insights content
5. Generic prompt/input wording
6. Duplicate/stacked box feel
7. Hardcoded layout hacks causing instability
8. Broken edits from blind patching
9. Mixed UI states causing regressions

---

## Current Confirmed Direction From Inspection
- The assistant exists as a floating header/card shell
- Suggestions are rendered in a horizontal `ListView.separated`
- Chips were oversized, then reduced
- Suggestions logic and visibility need stable separation
- Avatar exists but needs premium bubble/glass styling
- Header button must use chevron-style collapse, not cancel/X
- The app must resemble the reference screenshot more closely

---

## Final UX Target
Mira should feel like:
- a premium in-app AI guide
- calm and modern
- clear and feminine without being childish
- trustworthy and medically cautious
- focused on cycle intelligence, not generic chat

---

## Suggested Domain-Specific Prompt Set
Use prompts like:
1. When is my next period?
2. Am I in my fertile window?
3. What does this symptom mean?
4. Why is my cycle late?
5. Ovulation today?
6. Is my cycle irregular?
7. Pregnancy risk?
8. Hormonal imbalance signs?
9. PMS or something else?
10. Best time to conceive?

These can be refined further, but they must stay in-domain.

---

## Immediate Priorities

### Priority 1
Stabilize visibility logic:
- suggestions persist after tap
- no auto-hide behavior
- manual collapse only

### Priority 2
Replace close control style:
- use rounded chevron/down collapse button
- keep reliable collapse behavior

### Priority 3
Upgrade avatar:
- glass/bubble AI orb
- premium glow/highlight
- stronger identity presence

### Priority 4
Remove overlap feel:
- cleaner vertical spacing
- suggestions/input should not visually collide with underlying insight cards

### Priority 5
Refine copy:
- replace generic input/assistant messaging with cycle/fertility/symptom language

---

## Immediate Action Plan
1. Inspect current suggestion visibility logic
2. Inspect current chevron/collapse button block
3. Inspect input placeholder/copy
4. Inspect avatar block
5. Then apply targeted edits one by one with validation after each

---

## Non-Negotiable Reminder
If anything fails:
- stop
- inspect root
- then fix

Never continue patching blindly.
