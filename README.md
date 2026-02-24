# Flow Ai
## The Women’s Life, Wellness & Intelligence OS  
**By ZyraFlow GmbH™**

Flow Ai is an AI-native, privacy-first super-app designed to support every dimension of a woman’s daily life — **body, mind, relationships, ambition, and wellbeing** — within one calm, unified ecosystem.

Flow Ai is not a tracker.  
It’s a **Life Operating System (Life OS)** built to grow with a woman across decades.

---

## Core Principles
- Cycle-aware by default
- Emotionally intelligent UX
- Privacy + consent first
- Non-addictive, non-toxic engagement
- Culturally adaptive
- Long-term companionship (years, not sessions)
- Supportive and reflective — never prescriptive

---

## Modules (high level)
All modules are **optional** and **lazy-loaded**. Intelligence flows through a central layer (**FlowSense™**) and the UI only renders insights.

**Foundation**
- Cycle, hormones & body intelligence
- Mental health & emotional wellbeing (non-diagnostic)
- Nutrition & hydration
- Movement & recovery

**Life Context**
- Relationships & social wellbeing
- Work/school productivity (cycle-aware)
- Careers & talent coach (key differentiator)

**Opt-in**
- Pregnancy intelligence continuum (strict opt-in)
- Community/content (fully optional)
- Healthy gamification (optional)

---

## Safety Guardrails (Non-negotiable)
Flow Ai must never:
- Diagnose conditions or provide medical advice
- Predict pregnancy outcomes or monitor fetal health
- Provide treatment recommendations or risk scores
- Replace clinicians, midwives, or therapists

Flow Ai can:
- Reflect patterns relative to personal baseline
- Normalize experiences and offer educational context
- Encourage professional support when appropriate

---

## Architecture (Thin App, Thick Intelligence)
**Core Engine (always-on):** identity, consent, security, localization, local cache, feature flags.  
**FlowSense™ (central brain):** context resolving, pattern aggregation, insight generation, safety filter, explainability.  
**Modules (lazy-loaded):** speak to FlowSense™ only. Rule: **no module-to-module dependencies**.

---

## Development (Flutter)
### Requirements
- Flutter (stable)

### Run
```bash
flutter pub get
flutter gen-l10n
flutter run
flutter test
