# AGENTS.md

This file provides guidance to AI agents when working with code in this repository.

## Overview

This is a Nix-based dotfiles repository using Home Manager and flake-parts.
It manages configurations for two users (`erik` and `erasmussen`) — the same
person on two machines/OSes.
`modules/` holds generic, reusable, option-driven software configuration with
no identity baked in; personal preferences and identity (git email, editor
LSP/plugin choices, terminal colors, GNOME desktop, etc.) live under
`users/`, split into `users/shared/` (used by both identities) and
per-identity files (`users/erik/`, `users/erasmussen/`).
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

Note: `make build` validates the local flake (`$PWD`), while `make home` operates on `~/.config/home-manager`, a standalone flake whose only input is `github:UnstoppableMango/dotfiles`.
`make home` therefore applies whatever is on `main`, so local edits reach it only after a commit and a push.
To apply a local checkout instead, run `home-manager switch --flake $PWD -b hm-backup`.

Environment variables: `NIX`, `HOMEMANAGER`, `WATCHEXEC` (all have defaults).

CI runs `nix flake check --all-systems` then builds the `erik@darter` home configuration.

## Architecture

The flake uses `flake-parts`.
Home Manager modules are grouped by category under `modules/`, aggregated by
`modules/default.nix`, and imported by each user's home config in
`users/<user>/default.nix` alongside `users/shared/` (personal config common
to both identities: git identity/aliases, neovim's LSP/plugin choices, kitty
colors, zed extensions, vscode's default-profile settings, k9s's skin, and
the prezto/p10k setup) and identity-exclusive files (e.g. `users/erik/`'s
`desktop.nix` for GNOME and `vscode-hades.nix` for the Hades VS Code
profile, both gated behind host options set in `darter.nix`/`hades.nix`).
`modules/` itself stays generic — enable toggles and the mechanics needed for
a feature to function, with no personal values:

- `ai/` — claude-code, github-copilot-cli, cursor-cli (shared by both users).
  `global-context.md` is the user-level agent instructions, rendered to both `~/.claude/CLAUDE.md` and `~/.copilot/copilot-instructions.md`; `.claude/skills/agent-context/` covers how to change it.
  `omnigent.nix` treats `~/.omnigent/config.yaml` as runtime-owned (omnigent generates `host.host_id` there, and `omnigent config set --global` rewrites the whole file), so an activation script yq-assigns only the nix-declared `providers.openrouter` entry into it and leaves every sibling key alone.
  The OpenRouter key reaches that entry through an `auth_command` reading a `sops.secrets` path rather than `OPENROUTER_API_KEY` in the environment, since the systemd user unit running the server never sees a login shell (the same reasoning as `toolchain/git/opencommit.nix`).
  Enabled for erik only; erasmussen has no age key and cannot decrypt the secret.
- `automation/` — flake-update automation
- `browsers/` — Brave
- `editors/` — VS Code, Neovim (via nixvim), Zed, Helix, Emacs
- `fonts/` — Nerd Fonts (MesloLGS NF, FiraCode), opt-in via `dotfiles.fonts.enable`
- `gnupg/` — gpg + gpg-agent (shared by both users; pinentry only on Linux)
- `shells/` — Zsh (Prezto, or oh-my-zsh as an alt via `dotfiles.zsh.ohMyZsh.enable`; Powerlevel10k)
- `sops/` - shared sops-nix age key location (`~/.config/sops/age/keys.txt`), one module for both identities.
  Each identity's secrets live under its own `users/<name>/secrets/`, scoped in `.sops.yaml` to that identity's own key(s); hades also decrypts clan-generated material from the nixos repo.
- `ssh/` — SSH client config (shared by both users).
  Host aliases come from the `hosts` flake input (https://github.com/UnstoppableMango/hosts).
  The module takes the table as data (`dotfiles.ssh.hosts`, empty by default); `flake.nix` feeds it `inputs.hosts.lib.addresses`, so no module closes over `inputs` for it.
  Anything importing `homeModules.erik` from outside this flake has to set it too, which the nixos repo does in `machines/hades/configuration.nix`.
  That repo reads the same input for its `internet` clan service, so the two can't drift.
  `HostKeyAlias` plus the `@cert-authority` entry in `~/.ssh/known_hosts_nix` mean cluster machines validate against the clan SSH CA instead of prompting on first connect.
  Agent handling belongs to gnupg's gpg-agent, not here.
- `stylix/` — Stylix theming, scoped to terminals only (kitty, ghostty) via `dotfiles.stylix.enable`
- `terminals/` — Kitty, Ghostty
- `toolchain/` — per-language dev tool configs: c, containers, dotnet, git (`dotfiles.git.repos` declaratively inits repos under the home directory on activation), go, javascript, kubernetes (with k9s, openshift, and rosequartz submodules), nix, ocaml, python.
  `git/opencommit.nix` renders the whole of `~/.opencommit` through `sops.templates` when `dotfiles.git.openCommit.apiKeySecret` names a `sops.secrets` entry, because opencommit skips its own defaults entirely once that file exists.
  The file route rather than `OCO_API_KEY` in the environment, since the `prepare-commit-msg` hook also fires for editor and GUI commits that never see a login shell.
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
