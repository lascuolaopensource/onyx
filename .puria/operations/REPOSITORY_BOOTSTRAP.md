# REPOSITORY_BOOTSTRAP.md

This file defines the first action the GitHub Operator must perform on a new repository.

It does not replace `PURIA.md`.

---

## Purpose

Before creating implementation issues, milestones, branches, or phase pull requests, the GitHub Operator must bootstrap repository settings.

This prevents direct commits to `main` and makes the review workflow enforceable by GitHub, not only by agent instructions.

---

## Canonical command

Use the repository bootstrap script:

```sh
.puria/scripts/repo_settings_init.sh OWNER/REPO
```

When running inside the target repository, the repository argument can be omitted:

```sh
.puria/scripts/repo_settings_init.sh
```

---

## Required order

For every new repository, the GitHub Operator must run this order:

1. inspect repository and permissions
2. run `.puria/scripts/repo_settings_init.sh OWNER/REPO`
3. verify repository settings
4. verify default branch protection or ruleset
5. only then create project tracking and implementation tasks

---

## Script responsibilities

The script configures:

- squash merge only
- merge commits disabled
- rebase merge disabled
- automatic head branch deletion after merge
- pull request branch update button enabled
- default branch ruleset requiring pull requests
- one approval
- resolved conversations before merge
- force-push protection
- branch deletion protection

---

## Requirements

The script requires:

- `gh` CLI installed
- authenticated `gh` session
- repository administration permission

If project access is also needed later, refresh scopes with:

```sh
gh auth refresh -s repo -s project
```

---

## Verification

After bootstrap, verify repository settings:

```sh
gh repo view OWNER/REPO \
  --json allowMergeCommit,allowRebaseMerge,allowSquashMerge,deleteBranchOnMerge \
  --jq .
```

Verify the ruleset:

```sh
gh api /repos/OWNER/REPO/rulesets \
  --jq '.[] | select(.name == "protect-default-branch") | {id, name, target, enforcement}'
```

Verify active rules on the default branch:

```sh
DEFAULT_BRANCH="$(gh repo view OWNER/REPO --json defaultBranchRef --jq '.defaultBranchRef.name')"
gh api /repos/OWNER/REPO/rules/branches/$DEFAULT_BRANCH \
  --jq '.[] | {type}'
```

---

## Required GitHub Operator behavior

The GitHub Operator must run this as a dry run first unless the human explicitly allows mutation.

The dry run must show:

- target repository
- default branch
- current merge settings
- planned merge setting changes
- current protection/ruleset status
- planned protection/ruleset changes
- exact commands to run

---

## Failure behavior

If the GitHub Operator cannot configure protection:

- stop
- report the reason
- do not create implementation issues yet
- ask the human to grant repository administration permission or configure settings manually

---

## Final rule

No substantial agent implementation should start until repository protection is active or the human explicitly accepts the risk.
