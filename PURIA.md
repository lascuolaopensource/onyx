# PURIA.md

This file defines how work is done in this repository. As per Puria wishes.

It is the canonical source of truth for agents, assistants, humans, automation, and future maintainers.

If another instruction conflicts with this file:

→ STOP  
→ surface the conflict

---

## Enforcement Model

All rules in this document are mandatory unless explicitly stated otherwise.

If a rule is violated:

→ the task is considered incomplete  
→ the agent MUST correct it before finishing

Agents MUST NOT:

- ignore rules because they were not explicitly mentioned in the prompt
- assume rules are optional

---

## Prime Directive

Do not behave like a generic coding agent.

This repository expects opinionated, deterministic, reproducible engineering.

Prefer:

- clarity over cleverness
- explicitness over magic
- small steps over huge rewrites
- working code over speculative architecture
- tests over promises
- boring, maintainable solutions over fashionable abstractions

---

## Agent Boot Sequence

Before modifying anything:

1. Read `PURIA.md`
2. Inspect repository structure
3. Do NOT infer or adopt undocumented conventions
4. If a convention is observed but not defined in PURIA.md:
   → record it in `.puria/HITL.md`
5. Proceed using ONLY known rules from PURIA.md
6. Make the smallest safe change
7. Validate the change

Skipping any step is a failure.

---

## Default Expectations

Unless explicitly forbidden, every task MUST:

- produce a complete, runnable project
- include tests for core behavior
- include `mise.toml` with pinned Go version
- define required commands as mise tasks in `mise.toml`
- run `go fix ./...` for Go projects
- initialize git when creating projects
- create at least one valid commit
- leave the repository in a clean state

These requirements apply even if not mentioned in the prompt.

---

## Git Behavior

Agents MUST NOT push.

```sh
git push
```

is forbidden unless explicitly requested.

Before every commit, agents MUST verify the active commit identity.

Required identity check:

```sh
git config user.name
git config user.email
```

The identity MUST be the human or project-approved author identity.

Placeholder, test, example, or unknown identities are forbidden.

Forbidden examples include:

- `Test User`
- `test@example.com`
- `example@example.com`
- empty `user.name`
- empty `user.email`

If the identity is wrong or unclear:

→ STOP

→ fix the repository-local Git identity or ask the human

→ do NOT commit until the identity is correct

Before every commit, agents MUST run formatting and linting.

Required pre-commit validation:

```sh
mise run lint
```

Formatting MUST also be run through the repository-defined formatter before committing.

If the repository has no formatting task or formatter defined:

→ STOP

→ append the missing formatting rule to `.puria/HITL.md`

→ do NOT commit

If formatting or linting fails:

→ STOP

→ fix the issue

→ rerun formatting and linting

→ do NOT commit until both pass

A commit made without successful formatting and linting:

→ FAILURE

---

## Secrets And Ignore Files

Agents MUST NEVER commit secrets or sensitive data.

Sensitive data includes, but is not limited to:

- `.env`
- `.env.*`
- API keys
- access tokens
- private keys
- certificates
- credentials
- database dumps
- production configuration
- local machine paths containing secrets

Every new project MUST include a secure-by-default `.gitignore` before the first commit.

The `.gitignore` MUST ignore:

- environment files
- secret files
- private keys and certificates
- dependency directories
- build outputs
- logs
- caches
- editor and operating-system files
- local database files
- generated coverage artifacts

Before every commit, agents MUST inspect staged files for secrets and sensitive data.

If a secret or sensitive file is found staged:

→ STOP

→ unstage it

→ add or fix `.gitignore`

→ report the issue

→ do NOT commit until corrected

---

### Required Git State

A valid project MUST have:

- `.git` initialized
- files staged
- at least one commit

If missing:

→ FAILURE

---

### Commit Requirement

All commits MUST follow:

- Conventional Commits
- include `reason` and `prompt`

A repository without commits when expected:

→ FAILURE

---

## Commit Style

### Format

```text
<type>(<scope>): <subject>

reason:
<why>

prompt:
<short intent>
```

---

### Rules

- subject MUST be imperative, concise, lowercase
- MUST include `reason` and `prompt`
- MUST NOT describe the diff
- MUST explain intent

---

### Constraints

- reason: max 3 lines
- prompt: max 2 lines

---

### Failure Conditions

A commit is invalid if:

- missing `reason` or `prompt`
- describes only changes
- lacks intent

---

## Mandatory Project Skeleton (Go)

Every Go project MUST include:

```text
go.mod
mise.toml
.github/workflows/ci.yml
main.go
main_test.go
```

Absence of any:

→ FAILURE

---

## Go Toolchain

Every Go project MUST use the Go 1.26 series.

`go.mod` MUST declare:

```go.mod
go 1.26
```

`mise.toml` MUST define Go:

```toml
[tools]
go = "1.26.2"
node = "latest"
```

All project commands MUST be defined as mise tasks in `mise.toml`.

Do not add `Taskfile.yml`.

Do not add `task = "latest"` to `mise.toml`.

If `mise run lint:design` cannot run:

→ mise tasks are not configured correctly

→ the task remains incomplete until corrected

---

## Mise Tasks

`mise.toml` MUST include:

```toml
[tasks.test]
run = "go test ./..."

[tasks.fix]
run = "go fix ./..."

[tasks.format]
run = "gofmt -w ."

[tasks.lint]
depends = ["lint:design"]

[tasks."lint:design"]
run = "if [ -f .puria/design/DESIGN.md ]; then npx --yes @google/design.md lint .puria/design/DESIGN.md; fi"

[tasks.run]
run = "go run ."

[tasks.build]
run = "go build -o bin/starter ."
```

---

## GitHub Actions

Every Go project MUST include `.github/workflows/ci.yml`.

The GitHub workflow MUST run repository mise tasks.

The GitHub workflow MUST run `go fix ./...` before lint, test, and build.

The workflow MUST include:

```yaml
name: ci

on:
  pull_request:
  push:
    branches:
      - main

jobs:
  ci:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4

      - uses: jdx/mise-action@v2

      - run: mise run fix
      - run: git diff --exit-code
      - run: mise run lint
      - run: mise run test
      - run: mise run build
```

If `go fix ./...` modifies files:

→ the workflow MUST fail

→ the branch MUST be updated with the generated fixes

→ validation MUST be rerun

---

## Design Source

All Puria design MUST be neubrutalist.

If a task includes any web UI:

→ follow `https://neubrutalism.com` as the design reference

If a task includes TUI design:

→ apply neubrutalist principles to the terminal interface

Required neubrutalist traits:

- thick, explicit borders
- hard offset shadows where the medium supports them
- square or near-square corners
- flat high-contrast color
- bold typography
- visible structure
- clear hierarchy
- no gradients
- no soft, blurred, polished-neutral styling

If the project uses Svelte:

→ prefer existing neobrutalist Svelte components when they fit the task

If existing components do not fit:

→ implement custom components that follow the same neubrutalist design rules

`.puria/design/DESIGN.md` defines the mandatory Puria neubrutalist design system.

Agents MUST read `.puria/design/DESIGN.md` before any task that affects web UI, TUI, visual identity, layout, components, typography, colors, or design-bearing documentation.

If `.puria/design/DESIGN.md` is present:

→ it is the source of truth for design

→ agents MUST follow it

→ `mise.toml` MUST include `node = "latest"`

→ agents MUST validate it through `mise run lint`

→ `mise run lint` MUST depend on `lint:design`

→ `mise run lint:design` MUST run `npx --yes @google/design.md lint .puria/design/DESIGN.md`

If `.puria/design/DESIGN.md` is absent:

→ do not infer a design system

→ do not create one unless explicitly requested

---

## Testing Requirement

All executable code MUST have tests.

A task is incomplete if:

- no tests exist
- tests do not cover core behavior

---

## Repository Cleanliness

Forbidden:

- binaries in repo root
- logs
- temp folders
- test artifacts

Before completion:

```sh
git status --short
```

must be clean or explained.

---

## Engineering Style

Prefer:

- standard library
- small interfaces
- explicit errors
- deterministic behavior

Avoid:

- unnecessary dependencies
- magic
- over-engineering

---

## Planning Policy

Large tasks MUST be broken down.

Agents MUST:

- stop on oversized tasks
- propose phases
- agree before changing direction

---

## CLI Identity / ASCII Art

CLI tools MUST include ASCII art header.

Missing ASCII art:

→ FAILURE

---

## Web Identity / Console Signature

Web apps MUST include styled console signature.

Missing console identity:

→ FAILURE

## Required Developer Tools

If a repository requires a command to operate, that command MUST be declared in `mise.toml`.

A tool is required if it is used by:

- `mise.toml`
- tests
- build commands
- lint commands
- release commands
- validation instructions

Missing required tools in `mise.toml`:

→ FAILURE

---

## Standard Go mise.toml

Every Go project MUST declare Go and all required commands in `mise.toml`:

```toml
[tools]
go = "1.26.2"
node = "latest"

[tasks.fix]
run = "go fix ./..."

[tasks.format]
run = "gofmt -w ."

[tasks.test]
run = "go test ./..."

[tasks.lint]
depends = ["lint:design"]

[tasks."lint:design"]
run = "if [ -f .puria/design/DESIGN.md ]; then npx --yes @google/design.md lint .puria/design/DESIGN.md; fi"

[tasks.run]
run = "go run ."

[tasks.build]
run = "go build -o bin/starter ."
```

Agents MUST NOT create `Taskfile.yml`.

Agents MUST NOT add `task = "latest"` to `mise.toml`.

Then:

```sh
mise tasks
```

MUST show the required project commands.
