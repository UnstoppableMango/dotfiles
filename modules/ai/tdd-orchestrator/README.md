# tdd-orchestrator

Strict red/green/refactor TDD loop driven by three isolated subagents —
`tdd-red` writes failing tests, `tdd-green` writes the minimum impl to
pass them, `tdd-refactor` simplifies (Edit-only, can't create files).
Each phase runs in its own context window and can't touch the others'
files, so the agent can't quietly rubber-stamp its own tests.

Source Allies' `agentic-development-example` hub ships this as a
per-project install (`install.sh` symlinks `.claude/`,
`.github/agents/`, and `.agents/skills/` into the hub repo).
This copy is adapted for global installation instead: the orchestrator
already takes `target_repo` as an explicit dispatch parameter and reads
that repo's own `AGENTS.md` for language/test-framework/path
conventions, so nothing about the skill or agent logic needed to
change — only the delivery mechanism, from per-project symlinks to
`~/.claude/{skills,agents}` and `~/.copilot/{skills,agents}` via
[`../tdd-orchestrator.nix`](../tdd-orchestrator.nix)
(`dotfiles.ai.tddOrchestrator.enable`).

Works with both Claude Code and Copilot CLI — the hub's own design,
not something added here.

Not ported: the hub's own `README.md`, `AGENTS.md`, `CLAUDE.md`,
`.github/copilot-instructions.md`, and `install.sh` document the hub
repository itself (its layout, how to add new workflows, per-project
installation) rather than being part of the skill payload — only
`SKILL.md` and the three `*.agent.md` files are.
