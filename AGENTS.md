# AGENTS.md

This repository is governed by `PURIA.md`.
Agents MUST read `PURIA.md` before any action.
`PURIA.md` is the single source of truth for agent behavior, engineering style, workflow, git rules, commits, testing, releases, and project-specific doctrine.
`.puria/design/DESIGN.md` is the design source referenced by `PURIA.md`; agents MUST read it before any task that affects UI, TUI, visual identity, layout, components, typography, or colors.
`.puria/agents/GITHUB_OPERATOR.md` defines the GitHub Operator sub-agent; agents MUST read it before any task that creates or manages GitHub labels, milestones, issues, projects, branches, or pull requests.
`.puria/agents/AGENT_EXECUTION_WORKFLOW.md` defines the issue/project/PR execution workflow; agents MUST read it before turning plans into tracked work.
`.puria/agents/INTEGRATOR.md` defines the final integration agent; agents MUST read it before merging sub-agent outputs into a roadmap or implementation plan.
`.puria/agents/DEFAULT_PHASE_WORKFLOW.md` defines the mandatory default phase workflow for new projects and substantial work.
`.puria/operations/BRANCH_PROTECTION.md` defines the required repository-level enforcement for `main`.
`.puria/operations/REPOSITORY_BOOTSTRAP.md` defines the first GitHub Operator action for new repositories.
Before doing anything, agents MUST read `PURIA.md`.
If `PURIA.md` is missing, unreadable, or unclear:

→ STOP  
→ DO NOT modify files  
→ report the problem

There is no fallback behavior.
`PURIA.md` is the only source of truth.

---

## Execution

- Do NOT infer conventions
- Do NOT adopt undocumented patterns
- Use ONLY rules defined in `PURIA.md`
- For new projects and substantial work, use the mandatory phase workflow
- For new repositories, run repository bootstrap before implementation planning
- Do NOT commit substantial work directly to `main`; use a branch and pull request

If something looks like a convention but is not defined:

→ append it to `.puria/HITL.md`  
→ do NOT use it
