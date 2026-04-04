# CHECKLIST_DONE.md
> Definition of Done (DoD) for generic development harness

Mark each item: [x] pass / [ ] fail / [N/A]

## A. Scope & Requirements
- [ ] Change matches approved plan scope
- [ ] Non-goals remain untouched
- [ ] Any scope change documented (`PLAN_CHANGE_REQUEST`)

## B. Code Quality
- [ ] Code is readable and maintainable
- [ ] No obvious dead code / debug leftovers
- [ ] Naming and structure are consistent

## C. Verification
- [ ] Lint/format passed
- [ ] Typecheck passed (if applicable)
- [ ] Tests added/updated where needed
- [ ] Relevant tests pass locally/CI
- [ ] Build passes (if applicable)

## D. Reliability & Safety
- [ ] Edge cases considered
- [ ] Error handling is explicit and useful
- [ ] No sensitive data leakage in logs/responses
- [ ] Security-sensitive paths reviewed (auth/input/permissions)

## E. Performance (when relevant)
- [ ] No obvious performance regression
- [ ] Expensive operations are justified or mitigated

## F. Documentation & DX
- [ ] Docs/README updated if behavior changed
- [ ] Migration notes included (if needed)
- [ ] Usage examples updated (if applicable)

## G. Release Readiness
- [ ] Rollback strategy documented
- [ ] Known limitations documented
- [ ] Final summary prepared for handoff

---

## Verdict Rule

- Any fail in C or D => **NOT DONE**
- 2+ fails in A/B/F/G => **NOT DONE**
- Otherwise => **DONE WITH NOTES** or **DONE**
