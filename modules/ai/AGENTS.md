# modules/ai

This directory has two similarly-named files with different scopes.

- `agent-instructions.md` is deployed by home-manager to `~/.claude/CLAUDE.md` and `~/.copilot/copilot-instructions.md`.
It holds global, user-level agent preferences that apply across all projects on the machine.
Edit it to change personal preferences for how agents behave everywhere.

- This file, `AGENTS.md`, is not deployed anywhere.
It documents this specific directory for agents working in this repo, same as any other `AGENTS.md` in the tree.
