# AGENT_EXECUTION_WORKFLOW.md

This document defines a generic workflow for using agents, sub-agents, GitHub Issues, GitHub Projects, milestones, and pull requests together.

It does **not** replace `PURIA.md`.

If this document conflicts with `PURIA.md`:

→ STOP  
→ follow `PURIA.md`  
→ surface the conflict

---

## Purpose

This workflow exists to make large work executable in small, reviewable, testable steps.

Use it when a project needs:

- multiple agents or sub-agents
- weekly implementation slices
- GitHub issue tracking
- project-board visibility
- one pull request per delivery slice
- human review before merge

---

## Core workflow

```text
docs/specification
  ↓
sub-agent reports
  ↓
integration plan
  ↓
parent issues
  ↓
sub-issues
  ↓
one branch per delivery slice
  ↓
one PR per delivery slice
  ↓
human test/review/approve
  ↓
merge
  ↓
next slice
```

---

## GitHub structure

Use:

- GitHub Issues for executable work
- GitHub sub-issues for task breakdown
- GitHub issue dependencies for blocked/blocking relationships
- GitHub milestones for delivery slices
- GitHub Projects for planning, board views, roadmap views, and status tracking
- GitHub Pull Requests for reviewable implementation slices

---

## Issues vs Projects

Issues are the source of truth for work.

Projects are operational views over that work.

Use Issues for:

- task details
- acceptance criteria
- discussion
- dependencies
- sub-issues
- links to code
- links to PRs

Use Projects for:

- board view
- roadmap view
- status
- priority
- agent/owner
- risk
- mission impact
- progress visibility

---

## Milestone strategy

Create one milestone per delivery slice.

For weekly work, use:

```text
week-XX-theme
```

Each milestone should have:

- one parent issue
- multiple sub-issues
- one implementation PR
- one demo/checkpoint outcome

---

## Parent issue template

````md
# Week XX — <theme>

## Goal

## Mission relevance

Why this slice matters for the real-world objective.

## Deliverables

- [ ] ...

## Sub-issues

- [ ] #...
- [ ] #...
- [ ] #...

## Acceptance criteria

- [ ] ...

## Validation

```sh
<commands>
```

## Demo/checkpoint

What should be testable at the end of the slice.

## Risks

## Pull request

Branch:

```text
work/week-XX-theme
```

PR:

```text
TBD
```
````

---

## Sub-issue template

````md
# <task title>

## Context

## Scope

## Acceptance criteria

- [ ] ...

## Out of scope

## Dependencies

## Suggested files/modules

## Validation

```sh
<commands>
```

## Agent role

Recommended owner:

- mission-owner
- architect
- planner
- coder
- tester
- security
- devops
- docs
- integrator
- github-operator

## Notes
````

---

## Pull request template

````md
# <delivery slice>

## Summary

## Mission relevance

## Linked issues

Closes #...
Refs #...

## Scope

## Out of scope

## What changed

## Validation

```sh
<commands>
```

## Manual test checklist

- [ ] ...

## Screenshots

Required if UI changed.

## Database/migration notes

Required if schema changed.

## Deployment notes

Required if config, Docker, environment, or operational behavior changed.

## Security/privacy notes

Required if auth, personal data, secrets, LLMs, logging, or permissions changed.

## Known risks

## Follow-up issues

- [ ] #...
````

---

## Always-run agent loop

For mission-critical milestones, use this review loop:

1. Mission Owner checks real-world value.
2. Architect checks architecture and boundaries.
3. Planner creates executable issues and dependencies.
4. Coder implements assigned tasks.
5. Tester verifies acceptance criteria and test coverage.
6. Security & Privacy Reviewer checks safety and data concerns.
7. DevOps / Release Reviewer checks deployability and rollback concerns.
8. Documentation Reviewer checks docs and PR instructions.
9. Integrator resolves conflicts and prepares the final PR summary.

Not every role must edit files.

Only the assigned implementation agent should normally edit implementation code.

---

## Branch policy

Use one branch per delivery slice:

```text
work/week-XX-theme
```

Do not mix unrelated milestones in one branch.

If urgent fixes appear, create a separate fix branch and issue.

---

## PR approval policy

A PR can be approved only if:

- acceptance criteria are complete
- validation commands pass or failures are explained
- manual test checklist is complete
- mission relevance is clear
- docs are updated where needed
- migrations are documented
- deployment impact is documented
- security/privacy concerns are addressed
- follow-up issues exist for deferred work

---

## Definition of done

A delivery slice is done when:

- code is merged
- linked issues are closed or updated
- project board is updated
- milestone progress is updated
- follow-up issues are created
- next delivery slice is unblocked

---

## Mission reminder

The workflow is not the product.

The final question is always:

> Did this work move the project toward useful, working software?
