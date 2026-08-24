# AGENTS.md

This file provides guidance to AI agents when working with code in this repository.

## Overview

This is a Nix-based dotfiles repository using Home Manager and flake-parts.
It manages configurations for two users (`erik` and `erasmussen`) with modules grouped by category (browsers, editors, shells, etc.) rather than by user.
The actual NixOS system configs live at https://github.com/UnstoppableMango/nixos.

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

The flake uses `flake-parts`.
Home Manager modules are grouped by category under `modules/`, aggregated by `modules/default.nix`, and imported by each user's home config in `users/<user>/default.nix`:

- `ai/` — claude-code, github-copilot-cli, cursor-cli (shared by both users)
- `automation/` — flake-update automation
- `browsers/` — Brave
- `desktops/` — GNOME
- `editors/` — VS Code (with profiles per host), Neovim (via nixvim), Zed, Helix, Emacs
- `fonts/` — Nerd Fonts (MesloLGS NF, FiraCode), opt-in via `dotfiles.fonts.enable`
- `gnupg/` — gpg + gpg-agent (shared by both users; pinentry only on Linux)
- `shells/` — Zsh (Prezto, or oh-my-zsh as an alt via `dotfiles.zsh.ohMyZsh.enable`; Powerlevel10k)
- `sops/` - erik's sops-nix age key location (`~/.config/sops/age/keys.txt`).
  Imports sops-nix's home-manager module for every consumer; it is inert until something declares `sops.secrets`, so only hades actually decrypts anything.
- `ssh/` — SSH client config (shared by both users).
  Host aliases come from `hosts.nix` at the repo root, which the nixos repo also imports through its `dotfiles` flake input, so the `internet` clan service and this config can't drift.
  `HostKeyAlias` plus the `@cert-authority` entry in `~/.ssh/known_hosts_nix` mean cluster machines validate against the clan SSH CA instead of prompting on first connect.
  Agent handling belongs to gnupg's gpg-agent, not here.
- `stylix/` — Stylix theming, scoped to terminals only (kitty, ghostty) via `dotfiles.stylix.enable`
- `terminals/` — Kitty, Ghostty
- `toolchain/` — per-language dev tool configs: c, containers, dotnet, git (`dotfiles.git.repos` declaratively inits repos under the home directory on activation), go, javascript, kubernetes (with k9s, openshift, and rosequartz submodules), nix, ocaml, python.
  `kubernetes/rosequartz/` owns the shape of the rosequartz kubeconfig (contexts, VIP, dex OIDC exec block); the nixos repo supplies only the clan-generated CA and admin cert/key paths.
- `users/erik/` — Linux (x86_64) home config
- `users/erasmussen/` — macOS (aarch64-darwin) home config

Four home configurations are defined: `erik@darter`, `erik@hades`, and `erik@server` (all x86_64-linux; `server.nix` is a minimal headless profile — gnupg, shells, sops, ssh, toolchain only, no desktop/editor modules), and `erasmussen@Eriks-MacBook-Pro.local` (aarch64-darwin).

Overlays from multiple inputs (devctl, mynix, nil, nix-direnv, nix-vscode-extensions, ux) are composed in `flake.nix` and applied to nixpkgs. `zed.overlays.default` is currently commented out due to a `cargo-about` version conflict.

The dev shell (entered via `direnv allow` / `nix develop`) includes: age, bashInteractive, clan-cli, direnv, git, gnumake, home-manager, ldns, nil, nix, nixd, nixfmt, shellcheck, sops, ssh-to-age, watchexec.

## Formatting

- Nix files: `nixfmt` (via treefmt)
- JSON/Markdown/YAML/markup: `prettier` (via treefmt)
- Indentation: tabs everywhere except JSON/YAML/Nix which use 2 spaces (`.editorconfig`)

All formatters run through `treefmt-nix` (`nix fmt` / `make fmt`).

## Cachix

The CI uses the `unstoppablemango` Cachix cache. When building locally after CI has run, binaries should be available from cache.
