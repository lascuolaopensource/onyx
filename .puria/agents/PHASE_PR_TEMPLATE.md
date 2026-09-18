# PHASE_PR_TEMPLATE.md

Use this template for every phase pull request.

This file does not replace `PURIA.md`.

If this file conflicts with `PURIA.md`, stop, follow `PURIA.md`, and surface the conflict.

---

# Phase title

## Summary

Explain the phase in plain language.

## Mission relevance

Explain why this work matters for the real project goal.

## Linked issues

Closes issue numbers and reference related work.

## Implemented

- ...

## Not implemented / out of scope

- ...

## How to run

```sh
# commands
```

## How to check manually

The human reviewer should be able to follow this checklist without guessing.

- [ ] ...

## Expected behavior

Explain what the reviewer should see.

## Automated validation

```sh
# commands
```

If validation was not run, explain why.

## Tester report

Include what the Tester agent checked.

Required:

- acceptance criteria checked
- tests run
- edge cases checked
- missing tests
- confidence level

## Regression notes

Explain what might have regressed and how it was checked.

## Security/privacy notes

Required if the phase touches auth, secrets, personal data, LLMs, logging, permissions, or external systems.

## Deployment notes

Required if the phase changes config, Docker, migrations, infrastructure, jobs, or runtime behavior.

## Screenshots or evidence

Required if UI, CLI output, generated documents, or visible behavior changed.

## Known risks

- ...

## Follow-up issues

- ...

## Human feedback

Reviewer notes and requested changes belong here or in PR comments.
