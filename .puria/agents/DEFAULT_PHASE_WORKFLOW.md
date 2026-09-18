# DEFAULT_PHASE_WORKFLOW.md

This document defines the default phase-based workflow for new projects and substantial work.

It does not replace `PURIA.md`.

If this document conflicts with `PURIA.md`, stop and follow `PURIA.md`.

---

## Default behavior

When an agent is asked to create a new project or implement substantial work, it must use this workflow by default.

The agent must not jump directly into coding unless the task is tiny and clearly safe.

Default sequence:

1. understand the mission
2. create or update the implementation plan
3. split work into phases
4. create or prepare GitHub tracking
5. create parent issues and sub-issues
6. implement one phase at a time
7. open one PR per phase
8. include tester validation in the PR
9. keep the human reviewer in the loop
10. address feedback before continuing

---

## What counts as substantial work

Use this workflow when the task includes any of these:

- new project creation
- new application or service
- substantial feature
- multiple files or modules
- database changes
- deployment changes
- authentication or security changes
- personal data or secrets
- external integrations
- UI or CLI behavior that a human should test
- work that naturally spans phases

Small typo fixes and very small documentation edits may use the smaller safe-change workflow from `PURIA.md`.

If unsure, use this workflow.

---

## Human review requirement

The human must be able to review each phase from its PR.

Every phase PR must explain:

- what was implemented
- why it matters
- which issues it addresses
- what is out of scope
- how to run it
- how to check it manually
- what automated validation ran
- what the tester checked
- what might have regressed
- what remains to do

A PR is incomplete if the human cannot understand what changed and how to verify it.

---

## Required tracking

For each substantial project, prepare:

- GitHub Project or equivalent tracking board
- milestones or phases
- one parent issue per phase
- executable sub-issues
- dependencies where needed
- one branch per phase
- one PR per phase

The GitHub Operator should run dry-run first unless the human explicitly allows mutation.

---

## Required PR sections

Every phase PR must include:

- Summary
- Mission relevance
- Linked issues
- Implemented
- Not implemented or out of scope
- How to run
- How to check manually
- Expected behavior
- Automated validation
- Tester report
- Regression notes
- Security and privacy notes
- Deployment notes
- Screenshots or evidence when relevant
- Known risks
- Follow-up issues

---

## Tester responsibility

Before a phase PR is ready for human review, the Tester role must check:

- acceptance criteria
- core behavior
- edge cases
- regression risks
- automated validation
- manual validation instructions
- missing tests

If the tester cannot run validation, the PR must say why.

---

## Feedback loop

When the human gives feedback:

1. acknowledge it
2. convert it into PR comments, issue updates, or follow-up issues
3. update the phase PR if feedback is in scope
4. defer only with explicit explanation
5. do not continue to the next phase if current feedback blocks the mission

---

## Definition of done

A phase is done only when:

- phase PR is opened
- PR has complete human-checkable summary
- validation is complete or exceptions are documented
- tester report is included
- human feedback is addressed or explicitly deferred
- linked issues are updated
- follow-up issues exist for deferred work
- next phase is unblocked

---

## Final reminder

This workflow is mandatory for substantial work because human review is part of quality.

The goal is not process.

The goal is useful, reliable software with no hidden surprises.
