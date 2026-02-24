# Flow Ai — Module Dependency Blueprint
## Thin App, Thick Intelligence Architecture

This document defines the module dependency architecture for Flow Ai.

Goals:
- Keep the app calm, fast, and non-overwhelming
- Scale capability without increasing UI or cognitive load
- Enforce strict ethical, medical, and privacy boundaries

---

## Architectural First Principles
- Only the Core Engine is always active
- All other modules are optional and lazy-loaded
- No module depends directly on another module
- All intelligence flows through FlowSense™
- UI renders insights, never raw logic
- Unused modules consume zero compute

---

## 1) Core Engine (Always-on, Minimal Footprint)
Includes:
- Identity and profile management
- Consent and privacy manager
- Local cache and app state
- Feature flags / remote configuration
- Language and localization
- Security layer (authentication, app lock)

Rules:
- No business logic
- No health inference
- Must load instantly

Dependencies:
- None (root layer)

---

## 2) FlowSense™ Intelligence Layer (Central Brain)
Components:
- Pattern aggregator
- Context resolver
- Life-phase inference
- Insight generator
- Language safety filter
- Explainability layer

Rules:
- No UI rendering
- Mostly cloud-side execution
- Asynchronous by default

Dependencies:
- Core Engine only

---

## 3) Modules (Lazy-loaded)
Modules activate only when explicitly used or when the user opts in.

Examples:
- Cycle & hormones
- Mental wellbeing
- Nutrition
- Movement
- Relationships
- Career & talent (read-only context signals)
- Pregnancy continuum (strict opt-in)
- Community/content (optional, isolated)
- Healthy gamification (optional)

Rules:
- Modules communicate only via FlowSense™
- Modules do not call each other
- No cross-module mutation

---

## Forbidden Dependencies (Non-negotiable)
- Module-to-module direct dependency
- UI-to-intelligence coupling
- Automatic module activation without consent
- Medical logic inside consumer modules
- Persistent background compute for unused modules

