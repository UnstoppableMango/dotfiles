# AGENTS.md

This file provides guidance to AI agents when working with code in this repository.

## Overview

This is a Nix-based dotfiles repository using Home Manager and flake-parts.
It manages the home configuration for one user, `erik`, across several Linux hosts.
Three top-level directories, in dependency order:

- `modules/` - generic, reusable, option-driven software configuration, with no identity baked in.
  Declares `dotfiles.*` options; sets no personal values.
- `home/` - erik's identity: the account itself, git email, GNOME dconf, and secrets.
  Consumes `dotfiles.*`; declares none.
- `hosts/` - one file per home configuration (`darter`, `hades`, `server`, `generic`), plus `common.nix`, which every configuration is built on.
  The only entrypoints.
  Each lists the modules it turns on plus whatever is true of that machine alone.

See "Class vs Instance Modules" below for the full rule and a checklist to apply before adding or moving a file.
The actual NixOS system configs live at https://github.com/UnstoppableMango/nixos.

## Class vs Instance Modules

Every file in this repo falls into one of two buckets, and keeping that split clean is the main defense against structural drift.
`modules/` is the class bucket: it describes how a piece of software is configured, mechanically, with no identity baked in.
Personalization enters a class module only as a `dotfiles.<x>.<y>` option (data), never as a literal value.
`home/` is the instance bucket: it holds this person's actual values, and every file in it is gated on the `dotfiles.*` option its module declares, so importing it costs nothing on a host that has the feature switched off.
`hosts/` holds no personal values, only composition: a host says which modules it turns on plus what is true of it alone (a signing key, a kubeconfig path, a package it alone installs).
The account is identity rather than a class of machine, so it sits in `home/account.nix`; `hosts/server.nix` imports that one file directly because it takes the account without the rest of the personal layer.
`account.nix` itself carries no identity: `homeDirectory` derives from whatever `home.username` ends up being (`lib.mkDefault "/home/${config.home.username}"`), and it sets no username at all.
`home/default.nix` supplies the "erik" default as `home.username = lib.mkDefault "erik";`, so `home/default.nix` (which imports `account.nix`) can still be composed with a different username without a conflicting-definitions error, and `hosts/server.nix` sets its own username explicitly since it skips `home/default.nix`.

An opinionated value is not automatically identity.
A curated set that any consumer of this flake would plausibly want (the nixvim LSP and plugin list, the Powerlevel10k prompt config, the Zed extension list) belongs in `modules/` as an **option default** rather than as a literal in `home/`.
So do erik's curated _taste_ values: kitty's font and colors (`modules/kitty`), the k9s pink skin (`modules/kubernetes/k9s`), Zed's Copilot/telemetry settings (`modules/zed`), and the `~/src` checkout-root context doc (`modules/ai/checkout-root.nix`).
Each applies at `mkDefault` priority whenever its tool is enabled, so a consumer overrides a value with a plain assignment; there is no separate taste toggle.
`home/` keeps only what has no natural home as a module option default: the git email, the GNOME dconf tree, and the secrets.
The test is whether the next person would have to change the value, and whether no toggle already exists for saying so.
"Did someone choose this?" is the wrong question.

Before adding or moving a file, run this checklist:

1. Would a different person using this flake want a different value here?
   If yes, it is an instance and belongs under `home/`.
   If everyone would want the same mechanism, it is a class and belongs under `modules/`.
2. Does the file hardcode a literal (an email, a color hex, a hostname, an API key path, "this person's" editor choice)?
   That literal belongs in `home/`, or the class module needs to grow an option that `home/` supplies.
3. Is it an `enable` toggle rather than a value?
   Set it in each host file that wants it.
   Every host lists its toggles in full; there is no grouping layer between `modules/` and `hosts/`.
4. Is a module accreting config specific to one sub-tool (more than one or two files for it)?
   Split it into its own submodule directory with a `default.nix`, aggregated by the parent, rather than letting the parent module grow multiple unrelated concerns.
5. Would the value differ between machines?
   It goes in `hosts/<machine>.nix`, never as a per-host branch inside a class module.

Signals that a change is about to cause drift: hardcoding a literal inside `modules/`; declaring a `dotfiles.*` option outside `modules/`; a host file that sets a value that is not true of that machine alone; or a shared file of toggles that several hosts import.

There is deliberately no "shared across identities" layer.
This repo configures one identity, so such a layer would be an abstraction over a set of size one; its contents live in `home/`.

A second identity lives in its own flake and consumes `homeModules.dotfiles`, supplying its own toggles, account, secrets, and (on macOS) nix-darwin system layer.
That is why the reusable half of a shared layer belongs in `modules/` behind options rather than in a shared directory: an export is the sharing mechanism, so the layer is unnecessary.
`home/` therefore stays flat rather than becoming `home/<name>/`.

Precedent: the sops key path and the rosequartz kubeconfig describe erik's user environment rather than a clan machine, so they live in `modules/sops/` and `modules/kubernetes/rosequartz/` rather than in the nixos repo's `machines/hades/configuration.nix`, with the clan-generated CA and admin cert/key vendored in (`modules/kubernetes/rosequartz/ca.crt` and `home/secrets/rosequartz.yaml`) rather than reached for across repos.
The `kubernetes/` module carries `k9s/`, `openshift/`, and `rosequartz/` submodules, each tool's config being more than a single file, aggregated through `default.nix`.

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

Darter and hades both run standalone Home Manager, so `make home` and `make system` mean the same thing on either.
On hades `make system` rebuilds NixOS from the [nixos](https://github.com/UnstoppableMango/nixos) repo, which configures the machine and erik's system account and nothing about his home environment; that repo consumes this flake only for `overlays.default` and the dev shell.
Darter is not a NixOS machine, so only `make home` applies there.

Who may set `nixpkgs.*` follows from that.
Whoever creates the nixpkgs instance owns `nixpkgs.overlays` and `nixpkgs.config`, and for a standalone home configuration that is the configuration itself.
`hosts/common.nix` supplies both, once, so nothing under `modules/`, `home/`, or the per-configuration host files sets them.
That also keeps the tree composable into someone else's Home Manager NixOS module, where `useGlobalPkgs = true` hands ownership to the system and Home Manager warns that any `nixpkgs.*` set inside the home configuration is ignored.

`make build` builds a configuration picked from `hostname -s`: darter and hades build their own, macOS builds `generic@aarch64-darwin`, and any other Linux box falls back to `erik@server`.
Set `HOME_CONFIG` to build a different one, e.g. `make build HOME_CONFIG=erik@hades`.

Environment variables: `NIX`, `HOMEMANAGER`, `WATCHEXEC`, `HOME_CONFIG` (all have defaults).

CI runs `nix flake check --all-systems` then builds the `erik@darter` home configuration.

## Architecture

The flake uses `flake-parts`.
`modules/` is flat: one directory per piece of software, each with a `default.nix`.
There is no category layer, because deciding whether git is a `toolchain/` or a top-level concern, or whether kitty is `terminals/` or part of the shell setup, is a question with no correct answer and a different answer each time.
`modules/default.nix` imports every subdirectory that has a `default.nix`, read from disk rather than listed, so adding a module is creating the directory and nothing else.
Dropping a directory in there enables its options repo-wide, which is the tradeoff for not maintaining a list.
`hosts/common.nix` imports `homeModules.dotfiles` (`./modules` plus `tdl.homeModules.tdl`) and the stylix, nixvim, sops-nix, and nix2git modules once; `flake.nix` pairs it with each host file, so every configuration gets the whole option set.
Everything is `mkIf`-gated, so importing a module a host does not use costs nothing.

`home/default.nix` collects erik's personal config: git identity/aliases, vscode's default-profile settings, GNOME dconf taste, the direnv/nix-direnv setup, the sops secrets (and the `dotfiles.ai.omnigent.openRouter.apiKeySecret` naming one of them), and the `home.username` default.
`home/default.nix` and `home/account.nix` are reached by relative import (`hosts/darter.nix`, `hosts/hades.nix`, `hosts/server.nix`) rather than exported, since nothing outside this repo imports either by name.
The nixvim configuration, the prezto/p10k setup, the Zed extension list, and the kitty/k9s/zed/checkout-root taste all follow the same shape: the curated value is an option default in `modules/` (`dotfiles.neovim.defaultConfig`, `dotfiles.zsh.p10kConfig`, `dotfiles.zed.extensions`, `dotfiles.ai.checkoutRoot.context`, or an `mkDefault` on the tool's settings), reachable to anyone consuming the flake, and `home/` only overrides it rather than holding a literal value.
`home/vscode/hades.nix` is the one file `home/default.nix` does not import, because that VS Code profile exists on hades alone; `hosts/hades.nix` imports it directly.

Every `dotfiles.*` module is off by default, so importing `homeModules.dotfiles` turns nothing on.
Each host file lists every toggle it wants, even where hosts overlap, so reading one file tells you the whole configuration.

The omnigent OpenRouter provider has no toggle of its own to set: it turns on when `dotfiles.ai.omnigent.openRouter.apiKeySecret` names a secret, which only `home/` does.

`hosts/darter.nix` is the shell and secret floor, the dev toolchains and agent CLIs, and fonts, stylix, obsidian, and zed (a display without the desktop session), plus `targets.genericLinux`, its signing key, and the rosequartz KUBECONFIG.
`hosts/hades.nix` is the same floor and toolchains plus the full desktop session, ocaml, dotnet and emacs, its signing key, the LAN-facing omnigent and remote-control toggles, the rosequartz admin identity that makes it own `~/.kube/config` outright, and its desktop package list.
`hosts/server.nix` is `home/account.nix` plus the floor, containers, and kubernetes.
It deliberately does not import the rest of `home/`: the personal layer declares sops secrets encrypted to erik's laptop keys, which a server has no reason to hold.
Server does get prezto and Powerlevel10k, because it sets `dotfiles.zsh.enable` and that toggle is the prezto toggle.
A headless host that genuinely wants no prompt sets `dotfiles.zsh.p10kConfig = null`.

`modules/` itself stays generic, holding enable toggles and the mechanics needed for a feature to function, with no personal values:

- `ai/` - claude-code, github-copilot-cli, cursor-cli.
  Each MCP integration and third-party service (aws, azure, cloudflare, figma, slack, gossamer, per-language servers, etc.) gets its own `.nix` toggle file; `moer/`, `nix-skill/`, and `tdd-orchestrator/` are skill submodules (a SKILL.md plus agents), following the same one-file-per-concern pattern as the rest of `modules/`.
  `global-context.md` is the user-level agent instructions, rendered to both `~/.claude/CLAUDE.md` and `~/.copilot/copilot-instructions.md`; `.claude/skills/agent-context/` covers how to change it.
  `checkout-root.nix` renders `modules/ai/checkout-root.md` to `~/src/AGENTS.md` with a `CLAUDE.md` include beside it, matching the pairing the repos underneath use, so conventions spanning the whole checkout root are stated once instead of per repo.
  The document is an option, `dotfiles.ai.checkoutRoot.context`, defaulting to the bundled file; a consumer supplies their own or sets it to null to write nothing.
  `omnigent.nix` treats `~/.omnigent/config.yaml` as runtime-owned (omnigent generates `host.host_id` there, and `omnigent config set --global` rewrites the whole file), so an activation script yq-assigns only the nix-declared `providers.openrouter` entry into it and leaves every sibling key alone.
  The OpenRouter key reaches that entry through an `auth_command` reading a `sops.secrets` path rather than `OPENROUTER_API_KEY` in the environment, since the systemd user unit running the server never sees a login shell (the same reasoning as `git/opencommit.nix`).
  `coderabbit.nix` installs the CodeRabbit CLI from the `mangopkgs` overlay (packaged at `pkgs/coderabbit/` in https://github.com/unmango/pkgs) and turns its self-update off, since `coderabbit update` rewrites the binary in place and a nix-installed one lives in the read-only store.
  Authentication is a rendered `~/.coderabbit/auth.json` (`{"type":"api_key",...}`) rather than an environment variable, because the CLI reads no `CODERABBIT_API_KEY`; its api_key auth branch returns that file verbatim instead of consulting the OS credential store the OAuth branch uses, so the file alone is a complete authenticated state.
  The key comes from `dotfiles.ai.coderabbit.apiKeySecret` naming a `sops.secrets` entry, and the CLI rejects a user API key, so it has to be an agentic one.
- `flake-update/` - flake-update automation
- `brave/` - Brave
- `launch-services/`: macOS-only, and unreached, since no darwin configuration is defined.
  `launch-services.nix` registers the app bundles under `~/Applications/Home Manager Apps` with Launch Services (`lsregister`, which backs `open -a`, the Dock, and Launchpad) and the Spotlight metadata index (`mdimport`, which backs Cmd+Space) on every activation.
  Home Manager copies the bundles there but tells neither, and rsync writes them with normalized timestamps, so the fsevents that would trigger an automatic reindex do not reliably fire and an app can sit fully installed yet unreachable from every launcher.
  Both commands only refresh an index, so the activation entry warns instead of failing.
  Defaults to on for darwin and evaluates to nothing elsewhere.
- `vscode/`, `neovim/` (via nixvim), `zed/`, `helix/`, `emacs/`, `obsidian/` - editors.
  `neovim/nixvim-config.nix` is the curated LSP and plugin set, imported when `dotfiles.neovim.defaultConfig` is on and exported as `nixvimModules.default` so `packages.nixvim` builds the same configuration standalone.
  `zed/` carries the extension list as the `dotfiles.zed.extensions` default.
- `fonts/` - Nerd Fonts (MesloLGS NF, FiraCode), opt-in via `dotfiles.fonts.enable`
- `gnupg/` - gpg + gpg-agent (pinentry only on Linux, so macOS has no way to prompt for a passphrase and does not enable this module)
- `onepassword/` - 1Password CLI, the SSH agent socket, and SSH-format git commit signing through `op-ssh-sign`.
  The desktop app owns both the socket and the signing helper and is not installable from nixpkgs on macOS, so the module configures an app installed by hand rather than installing anything but the CLI.
  `dotfiles.onePassword.signingKey` takes the public half of the key as identity data from `home/`; the module holds no key material.
  Its SSH agent is exclusive with gpg-agent's `enableSshSupport` (both claim `SSH_AUTH_SOCK`), and an assertion fails the build on the overlap instead of letting it show up as a key that never offers itself.
- `zsh/` - Prezto, or oh-my-zsh as an alt via `dotfiles.zsh.ohMyZsh.enable`; Powerlevel10k.
  `prezto/` is a submodule holding the framework config and the bundled `.p10k.zsh`, which `dotfiles.zsh.p10kConfig` points at and a consumer can replace or set null.
  Both submodules follow `dotfiles.zsh.enable`, so a host that turns zsh on gets a framework rather than a bare shell.
- `sops/` - sops-nix age key location (`~/.config/sops/age/keys.txt`).
  Secrets live under `home/secrets/`, encrypted in `.sops.yaml` to erik's darter and hades keys so one file decrypts on both.
  `rosequartz.yaml` is the exception in origin rather than in handling: the admin cert and key are clan-generated in the nixos repo and re-encrypted here, so a rotation there has to be copied over the same way `modules/kubernetes/rosequartz/ca.crt` does.
- `ssh/` - SSH client config.
  Host aliases come from the `hosts` flake input (https://github.com/UnstoppableMango/hosts).
  The module takes the table as data (`dotfiles.ssh.hosts`, empty by default); `flake.nix` feeds it `inputs.hosts.lib.addresses`, so no module closes over `inputs` for it.
  `HostKeyAlias` plus the `@cert-authority` entry in `~/.ssh/known_hosts_nix` mean cluster machines validate against the clan SSH CA instead of prompting on first connect.
  Agent handling belongs to gnupg's gpg-agent, not here.
- `stylix/` - Stylix theming, scoped to terminals only (kitty, ghostty) via `dotfiles.stylix.enable`
- `kitty/`, `ghostty/` - terminals
- `c/`, `containers/`, `dotnet/`, `git/`, `go/`, `javascript/`, `kubernetes/`, `nix/`, `ocaml/`, `python/`, `rust/` - per-language dev tooling.
  There is no `tdl/` module: the tdl flake exports its own `homeModules.tdl` declaring `programs.tdl.*` (the CLI plus the VS Code extension), so `homeModules.dotfiles` folds that module in alongside `./modules` and a host sets `programs.tdl.enable`, rather than this repo re-declaring a `dotfiles.tdl` toggle over `pkgs.tdl`.
  `git/repos.nix` imports the nix2git home-manager module from https://github.com/unmango/nix2git, whose `nix2git.repositories` runs `git init` for declared paths under the home directory that do not exist yet, and never clones, rewrites, or deletes.
  `kubernetes/` keeps k9s, openshift, and rosequartz submodules.
  `git/opencommit.nix` renders the whole of `~/.opencommit` through `sops.templates` when `dotfiles.git.openCommit.apiKeySecret` names a `sops.secrets` entry, because opencommit skips its defaults entirely once that file exists.
  The file route rather than `OCO_API_KEY` in the environment, since the `prepare-commit-msg` hook also fires for editor and GUI commits that never see a login shell.
  `kubernetes/rosequartz/` owns the shape of the rosequartz kubeconfig (contexts, VIP, dex OIDC exec block); a host supplies the admin cert and key paths, and omitting them yields the OIDC context alone (which is what darter takes).
  `containers/` installs both stacks side by side: podman (with buildah, skopeo, podman-compose) and `docker-client`, the CLI without the daemon, since a system dockerd is outside Home Manager's reach.
  `docker compose` and `docker buildx` are linked into `~/.docker/cli-plugins` because the CLI resolves subcommands there rather than from PATH.
  `REGISTRY_AUTH_FILE` points podman, skopeo, and buildah at `~/.docker/config.json`, so one `docker login` serves both (`dotfiles.containers.sharedAuth`).
  `dotfiles.containers.podmanSocket` and `.userRegistryConfig` default to `targets.genericLinux.enable`: non-NixOS hosts get the rootless `podman.socket`/`podman.service` user units and `~/.config/containers/{policy.json,registries.conf}`, which the podman package carries no defaults for, while NixOS hosts keep the system layer's units and `/etc/containers` authoritative.
- `gnome/` - the GNOME option, the extension packages, and the derived `enabled-extensions` list.
  The dconf preferences that go with it are taste and live in `home/gnome.nix`.

Five home configurations are built: `erik@darter`, `erik@hades`, and `erik@server` on x86_64-linux, plus `generic@x86_64-linux` and `generic@aarch64-darwin`.
No machine is actually named `server`; that entry exists so `hosts/server.nix` is covered by `nix flake check` rather than only breaking whenever someone next touches it.

The two `generic@*` entries are the same idea one layer out: both build `hosts/generic.nix`, which turns most modules on (brave and gnome on Linux only), imports nothing from `home/`, and sets a throwaway account whose home directory follows the platform, so `homeModules.dotfiles` is built here rather than only breaking in somebody else's flake.
`generic@aarch64-darwin` is also the only consumer of the darwin branches in `modules/` (ghostty's null package, the 1Password agent socket, the containers defaults, omnigent's launchd unit, `launch-services/`).
`nix flake check` does not evaluate `homeConfigurations`, so CI builds them explicitly.
That takes two jobs: `check` on `ubuntu-latest` for the linux configurations, and `darwin` on `macos-latest` (Apple Silicon, so aarch64-darwin) for the darwin one, which gets a real build rather than an evaluation.

Overlays from multiple inputs (devctl, mangopkgs, nil, nix-direnv, nix-vscode-extensions, tdl) are composed in `flake.nix` and applied to nixpkgs, alongside the local ones from `overlays/`.
`zed.overlays.default` is commented out: nixpkgs' livekit-libwebrtc is out of sync with zed 0.217.3's expected webrtc API (`no type named 'AudioDeviceSink' in namespace 'webrtc'`).

`tdl.overlays.default` composes gomod2nix's overlay in (tdl is built with its `buildGoApplication`), so `buildGoApplication` and `mkGoEnv` land in `pkgs` alongside `tdl` and `vscode-tdl`.
`overlays/` holds the ones that are not a bare re-export of a flake input: `clan.nix` adapts an input's packages, and `vscode.nix` symlinks `node_modules.asar.unpacked` into the built product, without which oniguruma never loads and every file renders untokenized.
Software with no nixpkgs package and no upstream flake is packaged in https://github.com/unmango/pkgs and reaches this flake through the `mangopkgs` overlay, so a module can take it as a `package` option default the same as any nixpkgs attribute.
There is no `pkgs/` directory here.

The dev shell (entered via `direnv allow` / `nix develop`) includes: age, bashInteractive, clan-cli, direnv, git, gnumake, home-manager, ldns, nil, nix, nixd, nixfmt, shellcheck, sops, ssh-to-age, watchexec.

## Formatting

- Nix files: `nixfmt` (via treefmt)
- JSON/Markdown/YAML/markup: `prettier` (via treefmt)
- Indentation: tabs everywhere except JSON/YAML/Nix which use 2 spaces (`.editorconfig`)

All formatters run through `treefmt-nix` (`nix fmt` / `make fmt`).

## Cachix

The CI uses the `unstoppablemango` Cachix cache.
When building locally after CI has run, binaries should be available from cache.
