# WORKFLOW_FEATURE.md
> Purpose: Generic dev harness workflow for feature delivery
> Default pipeline: **Codex(Plan) → Claude(Build) → Codex(Review) → Claude(Fix)**
> Scope: New features and medium/large refactors

---

## 0) Inputs (required)

- Task brief (problem, goal, constraints)
- Target repo/module
- Acceptance criteria (user-visible + technical)
- Non-goals (explicitly out of scope)
- Deadline/priority

If any required input is missing, Planner must output `BLOCKED` with missing fields.

---

## 1) PLAN (Codex)

Planner must produce:

1. **Problem framing** (what/why)
2. **Implementation plan** (step-by-step, max 10 steps)
3. **File-level change map** (which files, why)
4. **Risk list** (top 3-5 risks)
5. **Test plan**
   - unit
   - integration
   - regression
6. **Rollback strategy**
7. **Definition of Done mapping** (to `CHECKLIST_DONE.md`)

### Plan output contract

Use this exact structure:

- Summary
- Scope / Non-scope
- Change Plan
- Files to Touch
- Risks & Mitigations
- Test Plan
- Rollback Plan
- Done Criteria

Planner output is saved as: `artifacts/plan/<task-id>.md`

---

## 2) PLAN LOCK

Builder must follow plan scope.
Any scope expansion requires a `PLAN_CHANGE_REQUEST` section:

- Why change is needed
- Proposed delta
- Risk impact
- Test impact

If change is significant, return to PLAN step.

---

## 3) BUILD (Claude)

Builder executes plan and must provide:

- Patch summary (what changed)
- Rationale per changed file
- Test evidence (commands + results)
- Known limitations

Builder output is saved as: `artifacts/build/<task-id>.md`

---

## 4) QUALITY GATE (automated)

Run (project-specific overrides allowed):

1. format/lint
2. typecheck
3. tests
4. build (if applicable)

If any gate fails:
- mark `GATE_FAILED`
- return failure logs
- enter FIX loop

---

## 5) REVIEW (Codex)

Reviewer validates:

- Plan adherence
- Correctness
- Edge cases
- Security/privacy concerns
- Performance red flags
- Test adequacy
- Maintainability

Review verdicts only:

- `APPROVED`
- `CHANGES_REQUESTED`
- `BLOCKED`

Reviewer output: `artifacts/review/<task-id>.md`

---

## 6) FIX LOOP (Claude)

If review = `CHANGES_REQUESTED`:
- Apply minimal targeted fixes
- Re-run Quality Gate
- Update build artifact delta section
- Return to REVIEW

Max loop count default: 3
If exceeded: escalate with concise blocker report.

---

## 7) FINAL DELIVERY

Final response must include:

- What shipped
- What was intentionally not done
- Validation evidence
- Risk notes (if any)
- Follow-ups (optional)

---

## 8) Fast-path for small tasks

For tiny changes (single-file, low risk), allow:
**Codex Plan-lite → Claude Build → Gate → Codex Quick Review**

Still requires:
- test/lint proof
- done checklist pass
