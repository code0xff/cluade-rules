# MODEL_ROUTING_POLICY.md
> Goal: keep harness model-agnostic while using strengths of each model.

## Default Role Assignment

- **Planner:** `openai-5.3-codex`
- **Builder:** `claude` (latest stable configured)
- **Reviewer:** `openai-5.3-codex` (default), fallback to claude when needed

---

## Routing Rules

## 1) Use Codex for:
- architecture planning
- ambiguous requirement disambiguation
- code review / defect hunting
- complex refactor strategy
- test strategy design

## 2) Use Claude for:
- implementation from a clear plan
- iterative code edits
- docs/comments polish
- repetitive transformations

## 3) Cross-check required when:
- auth/security/payment logic touched
- data migration included
- public API contract changed
- concurrency/perf-sensitive code touched

In these cases, reviewer must be different from builder.

---

## Fallback Policy

If assigned model fails (timeout/rate limit/tooling issue):

1. retry once (same model)
2. switch to fallback model
3. append `FALLBACK_USED` in artifact with reason

No silent model switching.

---

## Output Normalization

All models must emit these common sections:

- Assumptions
- Changes
- Test Evidence
- Risks
- Next Actions

This keeps outputs comparable and auditable.

---

## Context Budget Policy

- Planner: product/task docs + relevant architecture docs
- Builder: plan artifact + only required files
- Reviewer: diff + plan + test results (not full repo unless needed)

Avoid dumping entire repo context by default.

---

## Decision Log

Every task stores:

- chosen models per role
- fallback usage
- final verdict

Suggested path: `artifacts/meta/<task-id>.json`
