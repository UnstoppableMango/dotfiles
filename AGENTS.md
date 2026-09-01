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
See "Class vs Instance Modules" below for the full rule and a checklist to
apply before adding or moving a file.
The actual NixOS system configs live at https://github.com/UnstoppableMango/nixos.

## Class vs Instance Modules

Every file in this repo falls into one of two buckets, and keeping that split
clean is the main defense against structural drift.
`modules/` is the class bucket: it describes how a piece of software is
configured, mechanically, with no identity baked in.
Personalization enters a class module only as a `dotfiles.<x>.<y>` option
(data), never as a literal value.
`users/` is the instance bucket: it holds this person's actual values, split
into `users/shared/` (both identities use the same value) and
`users/<name>/` (identity-exclusive, often gated behind a host option such as
`darter.nix`/`hades.nix`).

Before adding or moving a file, run this checklist:

1. Would a different person using this flake want a different value here? If
   yes, it is an instance and belongs under `users/`. If everyone would want
   the same mechanism, it is a class and belongs under `modules/`.
2. Does the file hardcode a literal (an email, a color hex, a hostname, an
   API key path, "this person's" editor choice)? That literal belongs in
   `users/`, or the class module needs to grow an option that `users/`
   supplies.
3. Is the value identity-exclusive (only erik, only erasmussen) or shared by
   both? That decides `users/<name>/` vs `users/shared/`.
4. Is a module accreting config specific to one sub-tool (more than one or
   two files for it)? Split it into its own submodule directory with a
   `default.nix`, aggregated by the parent, rather than letting the parent
   module grow multiple unrelated concerns.
5. Would the value differ between machines/hosts for the same identity? Keep
   it a host-gated option supplied from `users/`, not a per-host branch
   hardcoded inside a class module.

Signals that a change is about to cause drift: hardcoding a literal inside
`modules/`; adding a second file for one sub-tool without splitting it into a
submodule; putting identity-exclusive config in `users/shared/`; or putting a
value both identities already share into only one `users/<name>/` file.

Precedent: the sops key path and the rosequartz kubeconfig describe erik's
user environment, not a clan machine, so they moved out of the nixos repo's
`machines/hades/configuration.nix` into `modules/sops/` and
`modules/toolchain/kubernetes/rosequartz/`, with only the clan-generated CA
and admin cert/key paths staying host-specific data supplied from outside.
The `toolchain/kubernetes/` module itself grew `k9s/`, `openshift/`, and
`rosequartz/` submodules as each tool's config outgrew a single file,
aggregated through `default.nix`.

## Common Commands

All development tasks go through `make`:

```sh
make check          # nix flake check (validate syntax/config)
make build          # build home-manager from local flake (validates changes)
make fmt            # format code (nix fmt)
make watch          # run checks on file changes (uses watchexec)
make home           # update flake and switch home-manager at ~/.config/home-manager
make system         # update flake and rebuild NixOS at /etc/nixos (requires sudo)
make darwin-build     # build the current host's darwin system closure (no sudo)
make darwin           # build, then darwin-rebuild switch the local flake (requires sudo)
make darwin-bootstrap # first activation, before darwin-rebuild is on PATH (requires sudo)
make update         # update flake inputs only
```

Note: `make build` validates the local flake (`$PWD`), while `make home` operates on `~/.config/home-manager`, a standalone flake whose only input is `github:UnstoppableMango/dotfiles`.
`make home` therefore applies whatever is on `main`, so local edits reach it only after a commit and a push.
To apply a local checkout instead, run `home-manager switch --flake $PWD#<config> -b hm-backup`.
That is for darter only: hades is activated by the nixos repo (see Architecture below).

On hades, erik's home is installed through the Home Manager NixOS module, not as a standalone Home Manager install.
There is no `home-manager` generation to switch there, so never suggest or run `home-manager switch` (or `make home`) for `erik@hades`; changes reach hades by landing on `main` and running `nixos-rebuild switch` from the [nixos](https://github.com/UnstoppableMango/nixos) repo.
`make build` and `nix build .#homeConfigurations."erik@hades".activationPackage` are the only things to run against that configuration here.
A standalone `home-manager switch` on hades resolves `erik@hades` and would rewrite the same sops-nix secrets directory without the clan-generated material the nixos repo layers on, leaving `~/.kube/config` dangling.
Nothing in the naming prevents that, so it is a rule to follow rather than a guard to rely on.
Darter is the standalone case and is the one the `home-manager switch` instructions above apply to.

`make darwin` builds before it switches so the sudo window is spent on activation rather than on evaluating and downloading.
It targets `darwinConfigurations.$(hostname -s)`, which matches the `scutil --get LocalHostName` that `darwin-rebuild` defaults to, and, unlike `make home`, it reads the local checkout, so darwin changes apply without a push.
`make darwin-bootstrap` is the same thing for the first run, resolving `darwin-rebuild` out of the built closure instead of PATH.
`darwin-rebuild switch` refuses to run as a non-root user and does not elevate itself, so the `sudo` prefix is required rather than incidental.

`make build` builds the current host's configuration, resolved as `$USER@$(hostname -s)`.
Set `HOME_CONFIG` to build a different one, e.g. `make build HOME_CONFIG=erik@server`.

Environment variables: `NIX`, `HOMEMANAGER`, `WATCHEXEC`, `HOME_CONFIG` (all have defaults).

CI runs `nix flake check --all-systems` then builds the `erik@darter` home configuration.

## Architecture

The flake uses `flake-parts`.
Home Manager modules are grouped by category under `modules/`, aggregated by
`modules/default.nix`, and imported by each user's home config in
`users/<user>/default.nix` alongside `users/shared/` (personal config common
to both identities: git identity/aliases, neovim's LSP/plugin choices, kitty
colors, zed extensions, vscode's default-profile settings, k9s's skin, the
`~/src` checkout-root document, and the prezto/p10k setup) and
identity-exclusive files (e.g. `users/erik/`'s `desktop.nix` for GNOME and
`vscode-hades.nix` for the Hades VS Code profile, both gated behind host
options set in `darter.nix`/`hades.nix`).
`modules/` itself stays generic — enable toggles and the mechanics needed for
a feature to function, with no personal values:

- `ai/` — claude-code, github-copilot-cli, cursor-cli (shared by both users).
  Each MCP integration and third-party service (aws, azure, cloudflare, figma,
  slack, gossamer, per-language servers, etc.) gets its own `.nix` toggle file;
  `moer/`, `nix-skill/`, and `tdd-orchestrator/` are skill submodules (a SKILL.md
  plus agents), following the same one-file-per-concern pattern as the rest of
  `modules/`.
  `global-context.md` is the user-level agent instructions, rendered to both `~/.claude/CLAUDE.md` and `~/.copilot/copilot-instructions.md`; `.claude/skills/agent-context/` covers how to change it.
  `checkout-root.nix` renders `users/shared/checkout-root.md` to `~/src/AGENTS.md` with a `CLAUDE.md` include beside it, matching the pairing the repos underneath use, so conventions spanning the whole checkout root are stated once instead of per repo.
  The module takes the document as an option (`dotfiles.ai.checkoutRoot.context`, null by default) and holds no content itself, so nothing in `modules/` assumes a checkout root exists.
  `omnigent.nix` treats `~/.omnigent/config.yaml` as runtime-owned (omnigent generates `host.host_id` there, and `omnigent config set --global` rewrites the whole file), so an activation script yq-assigns only the nix-declared `providers.openrouter` entry into it and leaves every sibling key alone.
  The OpenRouter key reaches that entry through an `auth_command` reading a `sops.secrets` path rather than `OPENROUTER_API_KEY` in the environment, since the systemd user unit running the server never sees a login shell (the same reasoning as `toolchain/git/opencommit.nix`).
  Enabled for erik only; erasmussen has no age key and cannot decrypt the secret.
- `automation/` — flake-update automation
- `browsers/` — Brave
- `darwin/`: macOS-only mechanics.
  `launch-services.nix` registers the app bundles under `~/Applications/Home Manager Apps` with Launch Services (`lsregister`, which backs `open -a`, the Dock, and Launchpad) and the Spotlight metadata index (`mdimport`, which backs Cmd+Space) on every activation.
  Home Manager copies the bundles there but tells neither, and rsync writes them with normalized timestamps, so the fsevents that would trigger an automatic reindex do not reliably fire and an app can sit fully installed yet unreachable from every launcher.
  Both commands only refresh an index, so the activation entry warns instead of failing.
  Defaults to on for darwin and evaluates to nothing elsewhere.
- `editors/` — VS Code, Neovim (via nixvim), Zed, Helix, Emacs, Obsidian
- `fonts/` — Nerd Fonts (MesloLGS NF, FiraCode), opt-in via `dotfiles.fonts.enable`
- `gnupg/` — gpg + gpg-agent (pinentry only on Linux, so macOS has no way to prompt for a passphrase and does not enable this module)
- `onepassword/` — 1Password CLI, the SSH agent socket, and SSH-format git commit signing through `op-ssh-sign`.
  The desktop app owns both the socket and the signing helper and is not installable from nixpkgs on macOS, so the module configures an app installed by hand rather than installing anything but the CLI.
  `dotfiles.onePassword.signingKey` takes the public half of the key as identity data from `users/`; the module holds no key material.
  Its SSH agent is exclusive with gpg-agent's `enableSshSupport` (both claim `SSH_AUTH_SOCK`), and an assertion fails the build on the overlap instead of letting it show up as a key that never offers itself.
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

Four home configurations are defined: `erik@darter`, `erik@hades`, and `erik@server` (all x86_64-linux; `server.nix` is a minimal headless profile — gnupg, shells, sops, ssh, toolchain only, no desktop/editor modules), and `erasmussen@Tractor-Zoom-Erik-Rasmussen.local` (aarch64-darwin).

The Mac runs a split install: `darwinConfigurations."Tractor-Zoom-Erik-Rasmussen"` (from `darwinModules.erasmussen`, i.e. `darwin/erasmussen/`) owns the system layer, and Home Manager stays a standalone install activated separately.
Home Manager is deliberately not wired in as a nix-darwin module, because that would make every home change cost a `darwin-rebuild switch`.
The account is not in the `admin` group and sudo is granted in five minute windows, so the split keeps `sudo` to system-layer changes only.

`darwin/erasmussen/` is the instance bucket for that layer, mirroring `users/erasmussen/`; the class/instance rule above applies to it unchanged.
`modules/darwin/` is _not_ its class counterpart: those are Home Manager modules that happen to be darwin-only (`launch-services.nix`), imported through `modules/default.nix` into the home config.
A generic nix-darwin module would belong in a new `darwin/modules/`, not in `modules/`, since the two module systems cannot share an import tree.

Two things follow from `nix.enable = true` there:
nix-darwin owns `/etc/nix/nix.conf` and the daemon, so substituters and `trusted-users` are declarative and no longer need a sudo window to change.
The first `darwin-rebuild switch` renames the installer's `/etc/nix/nix.conf` to `nix.conf.before-nix-darwin` on its own (its hash is in nix-darwin's `knownSha256Hashes`), so no manual move is needed.

Homebrew is a prerequisite, not something nix-darwin installs: `homebrew.enable = true` only runs `brew bundle` against an existing install.
`homebrew.caskArgs.appdir = "~/Applications"` because `brew bundle` runs as the unprivileged account during activation and `/Applications` is writable only by the `admin` group.
Ghostty comes from a cask because nixpkgs' `ghostty` is Linux-only; `modules/terminals/ghostty` sets `programs.ghostty.package` to `null` on darwin so Home Manager writes `~/.config/ghostty/config` for an app it does not install.
Shell integration keys off `$GHOSTTY_RESOURCES_DIR`, which the app exports at runtime, so it survives the missing package.

`docs/onboarding.md` is the checklist for bringing up a new machine: Nix install, flake entry, keys (1Password on macOS, GPG on Linux, sops age key either way), first activation, and where Home Manager puts macOS `.app` bundles.
Update it whenever one of those steps changes, since it is the only place the ordering is written down.

`erik@hades` is build-only.
Hades' home is activated by the nixos repo through the Home Manager NixOS module, which layers clan-generated material (the rosequartz kubeconfig and admin key) on top of `homeModules.erik`.
A standalone activation rewrites the same sops-nix secrets directory without that material, leaving `~/.kube/config` dangling, so never `switch` this configuration.
Build it with `nix run home-manager -- build --flake .#'erik@hades'`.

Overlays from multiple inputs (devctl, mynix, nil, nix-direnv, nix-vscode-extensions, ux) are composed in `flake.nix` and applied to nixpkgs. `zed.overlays.default` is currently commented out due to a `cargo-about` version conflict.

The dev shell (entered via `direnv allow` / `nix develop`) includes: age, bashInteractive, clan-cli, direnv, git, gnumake, home-manager, ldns, nil, nix, nixd, nixfmt, shellcheck, sops, ssh-to-age, watchexec.

## Formatting

- Nix files: `nixfmt` (via treefmt)
- JSON/Markdown/YAML/markup: `prettier` (via treefmt)
- Indentation: tabs everywhere except JSON/YAML/Nix which use 2 spaces (`.editorconfig`)

All formatters run through `treefmt-nix` (`nix fmt` / `make fmt`).

## Cachix

The CI uses the `unstoppablemango` Cachix cache. When building locally after CI has run, binaries should be available from cache.
