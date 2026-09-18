# WORKFLOW_ENFORCEMENT.md

This file defines the mandatory execution workflow for new projects and substantial implementation work.

It does **not** replace `PURIA.md`.

If this file conflicts with `PURIA.md`:

→ STOP  
→ follow `PURIA.md`  
→ surface the conflict

---

## Purpose

New projects and substantial implementation tasks MUST be planned, tracked, implemented, tested, and reviewed through a phase-based workflow.

The workflow exists to keep the human in the loop.

It ensures the human can always see:

- what is planned
- what is being implemented
- why it matters
- what changed
- how to test it
- what regressions were checked
- what remains unfinished

---

## Mandatory default

For every new project, agents MUST create or prepare:

- an implementation plan
- delivery phases
- GitHub tracking objects
- one parent issue per phase
- executable sub-issues
- one branch per phase
- one pull request per phase
- human-readable PR summaries
- validation instructions
- tester report
- regression notes

This is the default behavior.

It is not optional.

---

## When this workflow applies

This workflow applies when the task is any of the following:

- create a new project
- implement a new product or application
- implement a substantial feature
- make architectural changes
- change database schema
- change deployment behavior
- touch security, auth, secrets, or personal data
- modify several files or modules
- span more than one coding step
- require human testing or approval

For tiny changes, typo fixes, or single-file documentation edits, the agent may use the smaller safe-change workflow from `PURIA.md`.

If unsure, use the phase-based workflow.

---

## Required agent roles

For substantial work, agents MUST account for these roles:

1. Mission Owner
2. Architect
3. Planner
4. Coder
5. Tester
6. Security & Privacy Reviewer
7. DevOps / Release Reviewer
8. Documentation Reviewer
9. Integrator
10. GitHub Operator

Not every role needs to edit files.

Each role must either produce a report or be explicitly marked as not applicable with a reason.

---

## Required GitHub tracking

For every new project or substantial feature, the GitHub Operator MUST prepare tracking.

Required structure:

```text
GitHub Project
  Milestone or phase
    Parent issue
      Sub-issue
      Sub-issue
      Sub-issue
    Branch
    Pull request
```

Issues are the source of truth for work.

GitHub Projects are the operational view.

Pull requests are the human review boundary.

---

## Required phases

The Planner and Integrator MUST split work into phases.

Each phase must have:

- goal
- mission relevance
- deliverables
- sub-issues
- dependencies
- acceptance criteria
- validation commands
- demo or checkpoint
- risks
- PR scope

Each phase must produce something reviewable.

---

## One PR per phase

Each phase MUST have one pull request.

The PR is where the human reviews, tests, approves, rejects, or gives feedback.

A PR MUST NOT be a vague code dump.

Every PR MUST explain:

- what was implemented
- why it was implemented
- which issues it addresses
- what is intentionally out of scope
- how to run it
- how to test it manually
- what automated validation was run
- what the tester checked
- what regression risks exist
- what follow-up work remains

---

## Required PR body

Every phase PR MUST include:

````md
# <phase title>

## Summary

## Mission relevance

## Linked issues

Closes #...
Refs #...

## Implemented

- ...

## Not implemented / out of scope

- ...

## How to run

```sh
<commands>
```

## How to check manually

- [ ] ...

## Automated validation

```sh
<commands>
```

## Tester report

## Regression notes

## Security/privacy notes

## Deployment notes

## Screenshots or evidence

Required if UI, CLI output, generated documents, or visible behavior changed.

## Known risks

## Follow-up issues
````

---

## Human-in-the-loop rule

The human must be able to understand and verify every phase from the PR alone.

A PR is incomplete if the human cannot answer:

- what changed?
- why does it matter?
- how do I run it?
- how do I check it?
- what should I expect?
- what could have regressed?
- what remains to do?

---

## Tester requirement

Before a PR is marked ready for review, the Tester must check:

- acceptance criteria
- core behavior
- regression risks
- automated tests
- manual verification path
- missing tests

If validation could not run, the PR must say why.

---

## Feedback loop

If the human gives feedback on a PR:

1. convert feedback into issue comments or follow-up issues
2. update the PR or create a new PR depending on scope
3. do not silently ignore feedback
4. do not merge unresolved feedback unless explicitly approved

---

## Definition of done

A phase is done only when:

- the phase PR is reviewed
- validation is complete or exceptions are documented
- human feedback is addressed or explicitly deferred
- linked issues are closed or updated
- follow-up issues are created
- the next phase is unblocked

---

## Final reminder

This workflow is mandatory because human review is part of quality.

The goal is not process.

The goal is to ship useful, reliable software with no hidden surprises.
