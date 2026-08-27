---
name: agent-context
description: Edit the user-level agent instructions shared by Claude Code and Copilot CLI. Use when asked to add, change, or remove a global rule, remember a preference across all projects, or update ~/.claude/CLAUDE.md or ~/.copilot/copilot-instructions.md.
---

# Agent context

## The one file

Edit `modules/ai/global-context.md` in this repo.

Home Manager renders it to two places (`modules/ai/default.nix:63` and `modules/ai/default.nix:82`):

- `~/.claude/CLAUDE.md`
- `~/.copilot/copilot-instructions.md`

Both are symlinks into `/nix/store` and are read-only.
Writing to either fails, and an edit that appeared to succeed was written to the store path rather than the source.

## Pick the right scope

| The rule applies to           | Put it in                                                                                          |
| ----------------------------- | -------------------------------------------------------------------------------------------------- |
| Every project, every agent    | `modules/ai/global-context.md`                                                                     |
| This repo only                | `AGENTS.md` (`CLAUDE.md` and `.github/copilot-instructions.md` are one-line `@AGENTS.md` includes) |
| One project, outside nix      | `~/.claude/projects/<slug>/memory/`                                                                |
| A single task or conversation | Nowhere                                                                                            |

## What belongs

Durable cross-project preferences: writing style, commit conventions, language and toolchain rules, workarounds for environment quirks.

Reject:

- Facts specific to one repo, which belong in that repo's `AGENTS.md`.
- Anything carrying a date or a deadline.
- Anything the code, git history, or an existing `AGENTS.md` already records.

Each line is loaded into every agent session in every repo, so length has a standing cost.

## House style

The file states these rules and has to follow them:

- No em dash (U+2014). Use a comma, period, or parentheses.
- One sentence per line in markdown. Let the renderer wrap.
- No temporal or narrative phrasing ("now", "previously", "this was changed to"). Describe the current state as if it always held.

An edit that violates one of these contradicts the text sitting a few lines above it.

## Where to put it in the file

Sections, in order: a top-level bullet list, then `## English style`, `## Commit and PR conventions`, `## Bug fixing and review`, `## Docs and comments`, `## Nix`, `## Shell autoload issue`.

- Short cross-cutting mechanics go in the top bullet list.
- Anything else goes in the closest existing `## H2` section.
- Add a new `## H2` only when no section fits.

## Apply and verify

Format and validate:

```sh
command make fmt
command make check
command make build
```

`make build` runs `home-manager build --flake $PWD` and resolves the configuration from `$USER@$(hostname)`.

Apply the local checkout:

```sh
home-manager switch --flake $PWD -b hm-backup
```

Check that the text reached both render targets:

```sh
grep -n '<the new rule>' ~/.claude/CLAUDE.md ~/.copilot/copilot-instructions.md
```

`make home` is a different path: `~/.config/home-manager` is a standalone flake whose only input is `github:UnstoppableMango/dotfiles`, so it applies whatever is on `main`.
A local edit reaches `make home` only after a commit and a push.

## Commit

Conventional Commits, `docs:` for content-only changes.
