# BRANCH_PROTECTION.md

This file defines the required repository-level protection for `main`.

It does not replace `PURIA.md`.

Agent doctrine is not enough to prevent direct commits. The repository must enforce the workflow technically.

---

## Required rule

`main` MUST be protected.

Direct commits to `main` MUST NOT be allowed.

All substantial work MUST go through a pull request.

---

## First GitHub Operator action

For every new repository, the GitHub Operator MUST run `.puria/operations/REPOSITORY_BOOTSTRAP.md` before creating implementation issues, milestones, project boards, branches, or pull requests.

The bootstrap must configure:

- squash merge only
- merge commits disabled
- rebase merge disabled
- automatic head branch deletion after merge
- pull request branch update button enabled
- default branch protection or ruleset
- pull-request-only changes to `main`
- at least one required approval
- resolved conversations before merge
- force pushes blocked
- branch deletion blocked

---

## What can be automated

The GitHub Operator can automate these settings with `gh api` when it has repository administration permission:

- repository merge settings
- squash-only merge policy
- automatic deletion of head branches after merge
- pull request branch update button
- repository rulesets
- branch protection

If the token lacks permission, the GitHub Operator must stop and ask the human to grant permission or configure the settings manually.

---

## Required GitHub settings

Configure a branch protection rule or repository ruleset for `main` with these requirements:

- require a pull request before merging
- require at least one approval
- require conversation resolution before merging
- block force pushes
- block branch deletion
- restrict who can push to `main` where practical
- include administrators if available

---

## Required agent behavior

Agents MUST NOT write directly to `main` for substantial work.

Agents MUST:

1. create a branch
2. make changes on the branch
3. open a draft pull request
4. include the required phase PR summary
5. wait for human review or explicit approval

---

## Human review boundary

The pull request is the human review boundary.

Every substantial PR must explain:

- what changed
- why it matters
- how to run it
- how to check it manually
- what validation ran
- what the tester checked
- what could regress
- what remains to do

---

## Emergency exception

Emergency direct changes to `main` are allowed only with explicit human instruction.

The agent must record the reason in the final report.

---

## Final reminder

This exists because agents can make mistakes.

The repository must enforce the workflow even when an agent forgets.
