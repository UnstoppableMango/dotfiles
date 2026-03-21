# AGENTS.md

This file provides guidance to AI agents when working with code in this repository.

## Overview

This is a Nix-based dotfiles repository using Home Manager and flake-parts. It manages configurations for two users (`erik` and `erasmussen`) using the "Dendritic Pattern" — modules grouped by category (browsers, editors, shells, etc.) rather than by user. The actual NixOS system configs live at https://github.com/UnstoppableMango/nixos.

## Common Commands

All development tasks go through `make`:

```sh
make check          # nix flake check (validate syntax/config)
make build          # build home-manager configuration
make fmt            # format code (nix fmt)
make watch          # run checks on file changes (uses watchexec)
make home           # update flake and switch home-manager for current user
make update         # update flake inputs only
```

Environment variables: `NIX`, `HOMEMANAGER`, `WATCHEXEC` (all have defaults).

CI runs `nix flake check --all-systems` then builds the `erik` home configuration.

## Architecture

The flake uses `flake-parts` with these categorical module directories imported as `flake.modules.flake`:

- `browsers/` — Brave
- `desktops/` — GNOME
- `editors/` — VS Code, Neovim (via nixvim), Zed, Helix, Emacs, Nano
- `shells/` — Zsh (Prezto + Powerlevel10k)
- `terminals/` — Kitty, Ghostty
- `toolchain/` — per-language dev tool configs (git, go, dotnet, containers, kubernetes, nix, etc.)
- `users/erik/` and `users/erasmussen/` — user-specific home configurations

Overlays from multiple inputs (bun2nix, devctl, gomod2nix, mynix, nil, nix-direnv, nix-vscode-extensions) are composed in `flake.nix` and applied to nixpkgs.

The dev shell (entered via `direnv allow` / `nix develop`) includes tools such as: direnv, dprint, git, gnumake, home-manager, nil, nixd, nixfmt, shellcheck, watchexec.

## Formatting

- Nix files: `nixfmt` (via treefmt)
- JSON/Markdown/YAML: `dprint` (configured in `.dprint.json`)
- Indentation: tabs everywhere except JSON/YAML/Nix which use 2 spaces (`.editorconfig`)

Note: dprint is currently disabled in the treefmt flake module due to `nix flake check` issues.

## Cachix

The CI uses the `unstoppablemango` Cachix cache. When building locally after CI has run, binaries should be available from cache.
