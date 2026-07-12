# AGENTS.md

This file provides guidance to AI agents when working with code in this repository.

## Overview

This is a Nix-based dotfiles repository using Home Manager and flake-parts. It manages configurations for two users (`erik` and `erasmussen`) using the "Dendritic Pattern" — modules grouped by category (browsers, editors, shells, etc.) rather than by user. The actual NixOS system configs live at https://github.com/UnstoppableMango/nixos.

## Common Commands

All development tasks go through `make`:

```sh
make check          # nix flake check (validate syntax/config)
make build          # build home-manager from local flake (validates changes)
make fmt            # format code (nix fmt)
make watch          # run checks on file changes (uses watchexec)
make home           # update flake and switch home-manager at ~/.config/home-manager
make system         # update flake and rebuild NixOS at /etc/nixos (requires sudo)
make update         # update flake inputs only
```

Note: `make build` validates the local flake (`$PWD`), while `make home` operates on `~/.config/home-manager` (the installed config, typically a symlink to this repo).

Environment variables: `NIX`, `HOMEMANAGER`, `WATCHEXEC` (all have defaults).

CI runs `nix flake check --all-systems` then builds the `erik@darter` home configuration.

## Architecture

The flake uses `flake-parts` with these categorical module directories imported as `flake.modules.flake`:

- `ai/` — claude-code, github-copilot-cli, cursor-cli (shared by both users)
- `browsers/` — Brave
- `desktops/` — GNOME
- `editors/` — VS Code (with profiles per host), Neovim (via nixvim), Zed, Helix, Emacs
- `gnupg/` — gpg + gpg-agent (shared by both users; pinentry only on Linux)
- `shells/` — Zsh (Prezto, or oh-my-zsh as an alt via `dotfiles.zsh.ohMyZsh.enable`; Powerlevel10k)
- `terminals/` — Kitty, Ghostty
- `toolchain/` — per-language dev tool configs: c, containers, dotnet, git, go, javascript, kubernetes (with k9s and openshift submodules), nix, ocaml, python
- `users/erik/` — Linux (x86_64) home config
- `users/erasmussen/` — macOS (aarch64-darwin) home config

Three home configurations are defined: `erik@darter` and `erik@hades` (both x86_64-linux), and `erasmussen@Eriks-MacBook-Pro.local` (aarch64-darwin).

Overlays from multiple inputs (devctl, mynix, nil, nix-direnv, nix-vscode-extensions, ux) are composed in `flake.nix` and applied to nixpkgs. `zed.overlays.default` is currently commented out due to a `cargo-about` version conflict.

The dev shell (entered via `direnv allow` / `nix develop`) includes: age, bashInteractive, clan-cli, direnv, dprint, git, gnumake, home-manager, ldns, nil, nix, nixd, nixfmt, shellcheck, ssh-to-age, watchexec.

## Formatting

- Nix files: `nixfmt` (via treefmt)
- JSON/Markdown/YAML: `dprint` (configured in `.dprint.json`)
- Indentation: tabs everywhere except JSON/YAML/Nix which use 2 spaces (`.editorconfig`)

Note: dprint is currently disabled in the treefmt flake module due to `nix flake check` issues.

## Cachix

The CI uses the `unstoppablemango` Cachix cache. When building locally after CI has run, binaries should be available from cache.
