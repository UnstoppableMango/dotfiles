# AGENTS.md

This file provides guidance to AI agents when working with code in this repository.

## Overview

This is a Nix-based dotfiles repository using Home Manager and flake-parts.
It manages the home configuration for one user, `erik`, across several Linux
hosts.
`modules/` holds generic, reusable, option-driven software configuration with
no identity baked in; personal preferences and identity (git email, editor
LSP/plugin choices, terminal colors, GNOME desktop, etc.) live under
`users/erik/`.
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
`users/erik/` is the instance bucket: it holds this person's actual values.
A value that every host shares sits in a plain file imported by
`users/erik/default.nix`; a value that differs per machine is a host-gated
option set from `darter.nix`/`hades.nix`/`server.nix`.

Before adding or moving a file, run this checklist:

1. Would a different person using this flake want a different value here? If
   yes, it is an instance and belongs under `users/erik/`. If everyone would
   want the same mechanism, it is a class and belongs under `modules/`.
2. Does the file hardcode a literal (an email, a color hex, a hostname, an
   API key path, "this person's" editor choice)? That literal belongs in
   `users/erik/`, or the class module needs to grow an option that
   `users/erik/` supplies.
3. Is a module accreting config specific to one sub-tool (more than one or
   two files for it)? Split it into its own submodule directory with a
   `default.nix`, aggregated by the parent, rather than letting the parent
   module grow multiple unrelated concerns.
4. Would the value differ between machines/hosts? Keep it a host-gated option
   supplied from the host file, not a per-host branch hardcoded inside a class
   module.

Signals that a change is about to cause drift: hardcoding a literal inside
`modules/`; adding a second file for one sub-tool without splitting it into a
submodule; or putting a value every host shares into a single host file.

There is deliberately no "shared across identities" layer. This repo had one
when it also configured a second identity (`erasmussen`, on macOS). With that
identity gone, `users/shared/` was an abstraction over a set of size one, and
its contents now live directly in `users/erik/`. Do not reintroduce it for a
second identity without a second identity actually existing.

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

That split also fixes who may set `nixpkgs.*`.
Whoever creates the nixpkgs instance owns `nixpkgs.overlays` and `nixpkgs.config`; under the Home Manager NixOS module with `useGlobalPkgs = true` that is the system, and Home Manager warns that any `nixpkgs.*` set inside the home configuration is ignored.
So nothing under `modules/` or `users/` sets them.
`flake.nix`'s `common` list supplies both to the standalone configurations, and the nixos repo supplies them to hades.

`make build` builds the current host's configuration, resolved as `$USER@$(hostname -s)`.
Set `HOME_CONFIG` to build a different one, e.g. `make build HOME_CONFIG=erik@hades`.

Environment variables: `NIX`, `HOMEMANAGER`, `WATCHEXEC`, `HOME_CONFIG` (all have defaults).

CI runs `nix flake check --all-systems` then builds the `erik@darter` home configuration.

## Architecture

The flake uses `flake-parts`.
Home Manager modules are grouped by category under `modules/`, aggregated by
`modules/default.nix`, and imported by `users/erik/default.nix` alongside
erik's own personal config: git identity/aliases, neovim's LSP/plugin choices,
kitty colors, zed extensions, vscode's default-profile settings, k9s's skin,
the `~/src` checkout-root document, and the prezto/p10k setup.
Host-exclusive files sit beside them (`desktop.nix` for GNOME, `vscode/hades.nix`
for the Hades VS Code profile), gated behind host options set in
`darter.nix`/`hades.nix`.
`modules/` itself stays generic — enable toggles and the mechanics needed for
a feature to function, with no personal values:

- `ai/` — claude-code, github-copilot-cli, cursor-cli.
  Each MCP integration and third-party service (aws, azure, cloudflare, figma,
  slack, gossamer, per-language servers, etc.) gets its own `.nix` toggle file;
  `moer/`, `nix-skill/`, and `tdd-orchestrator/` are skill submodules (a SKILL.md
  plus agents), following the same one-file-per-concern pattern as the rest of
  `modules/`.
  `global-context.md` is the user-level agent instructions, rendered to both `~/.claude/CLAUDE.md` and `~/.copilot/copilot-instructions.md`; `.claude/skills/agent-context/` covers how to change it.
  `checkout-root.nix` renders `users/erik/checkout-root.md` to `~/src/AGENTS.md` with a `CLAUDE.md` include beside it, matching the pairing the repos underneath use, so conventions spanning the whole checkout root are stated once instead of per repo.
  The module takes the document as an option (`dotfiles.ai.checkoutRoot.context`, null by default) and holds no content itself, so nothing in `modules/` assumes a checkout root exists.
  `omnigent.nix` treats `~/.omnigent/config.yaml` as runtime-owned (omnigent generates `host.host_id` there, and `omnigent config set --global` rewrites the whole file), so an activation script yq-assigns only the nix-declared `providers.openrouter` entry into it and leaves every sibling key alone.
  The OpenRouter key reaches that entry through an `auth_command` reading a `sops.secrets` path rather than `OPENROUTER_API_KEY` in the environment, since the systemd user unit running the server never sees a login shell (the same reasoning as `toolchain/git/opencommit.nix`).
- `automation/` — flake-update automation
- `browsers/` — Brave
- `darwin/`: macOS-only mechanics, currently unreached — no darwin configuration is defined.
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
- `sops/` - sops-nix age key location (`~/.config/sops/age/keys.txt`).
  Secrets live under `users/erik/secrets/`, encrypted in `.sops.yaml` to erik's darter and hades keys so one file decrypts on both; hades also decrypts clan-generated material from the nixos repo.
- `ssh/` — SSH client config.
  Host aliases come from the `hosts` flake input (https://github.com/UnstoppableMango/hosts).
  The module takes the table as data (`dotfiles.ssh.hosts`, empty by default); `flake.nix` feeds it `inputs.hosts.lib.addresses`, so no module closes over `inputs` for it.
  Anything importing `homeModules.erik` from outside this flake has to set it too, which the nixos repo does in `machines/hades/configuration.nix`.
  That repo reads the same input for its `internet` clan service, so the two can't drift.
  `HostKeyAlias` plus the `@cert-authority` entry in `~/.ssh/known_hosts_nix` mean cluster machines validate against the clan SSH CA instead of prompting on first connect.
  Agent handling belongs to gnupg's gpg-agent, not here.
- `stylix/` — Stylix theming, scoped to terminals only (kitty, ghostty) via `dotfiles.stylix.enable`
- `terminals/` — Kitty, Ghostty
- `toolchain/` — per-language dev tool configs: c, containers, dotnet, git (`repos.nix` imports the nix2git home-manager module from https://gitlab.com/unmango/nix/2git, whose `nix2git.repositories` runs `git init` for declared paths under the home directory that do not exist yet, and never clones, rewrites, or deletes), go, javascript, kubernetes (with k9s, openshift, and rosequartz submodules), nix, ocaml, python.
  `git/opencommit.nix` renders the whole of `~/.opencommit` through `sops.templates` when `dotfiles.git.openCommit.apiKeySecret` names a `sops.secrets` entry, because opencommit skips its own defaults entirely once that file exists.
  The file route rather than `OCO_API_KEY` in the environment, since the `prepare-commit-msg` hook also fires for editor and GUI commits that never see a login shell.
  `kubernetes/rosequartz/` owns the shape of the rosequartz kubeconfig (contexts, VIP, dex OIDC exec block); the nixos repo supplies only the clan-generated CA and admin cert/key paths.
  `containers/` installs both stacks side by side: podman (with buildah, skopeo, podman-compose) and `docker-client`, the CLI without the daemon, since a system dockerd is outside Home Manager's reach.
  `docker compose` and `docker buildx` are linked into `~/.docker/cli-plugins` because the CLI resolves subcommands there rather than from PATH.
  `REGISTRY_AUTH_FILE` points podman, skopeo, and buildah at `~/.docker/config.json`, so one `docker login` serves both (`dotfiles.containers.sharedAuth`).
  `dotfiles.containers.podmanSocket` and `.userRegistryConfig` default to `targets.genericLinux.enable`: non-NixOS hosts get the rootless `podman.socket`/`podman.service` user units and `~/.config/containers/{policy.json,registries.conf}`, which the podman package carries no defaults for, while NixOS hosts keep the system layer's units and `/etc/containers` authoritative.
- `users/erik/` — erik's home config: identity, taste, and the per-host files
  (`darter.nix`, `hades.nix`, `server.nix`)

Two home configurations are built here, `erik@darter` and `erik@hades`, both x86_64-linux.
`homeModules.server` (`users/erik/server.nix`) is a minimal headless profile — gnupg, shells, sops, ssh, toolchain only, no desktop or editor modules — exported for other flakes to consume rather than instantiated as a `homeConfiguration`.

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
