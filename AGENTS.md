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
make home           # switch home-manager from this checkout
make system         # update flake and rebuild NixOS at /etc/nixos (requires sudo)
make update         # update flake inputs only
```

Both `make build` and `make home` act on the local flake (`${CURDIR}`), so a switch applies the working tree and the active home matches the checkout.
Input updates stay deliberate: `make update` bumps `flake.lock`, and that lands as a commit.

`homeup` is the same switch from any directory, installed by `modules/home-manager/` for hosts that set `dotfiles.homeManager.enable`.
It switches from `dotfiles.homeManager.flakePath` (`~/src/github.com/UnstoppableMango/dotfiles` by default), lets home-manager resolve `$USER@$HOSTNAME` unless `dotfiles.homeManager.configuration` names one, and passes any unrecognized argument through to `home-manager switch`.
`homeup -u` runs `nix flake update` first, which rewrites `flake.lock` in the checkout.

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

`home/default.nix` collects erik's personal config: git identity/aliases, vscode's default-profile settings, GNOME dconf taste, the direnv/nix-direnv setup, the sops secrets (and `dotfiles.openrouter.apiKeySecret` naming the OpenRouter key), and the `home.username` default.
`home/default.nix` and `home/account.nix` are reached by relative import (`hosts/darter.nix`, `hosts/hades.nix`, `hosts/server.nix`) rather than exported, since nothing outside this repo imports either by name.
The nixvim configuration, the p10k setup, the Zed extension list, and the kitty/k9s/zed/checkout-root taste all follow the same shape: the curated value is an option default in `modules/` (`dotfiles.neovim.defaultConfig`, `dotfiles.zsh.p10kConfig`, `dotfiles.zed.extensions`, `dotfiles.ai.checkoutRoot.context`, or an `mkDefault` on the tool's settings), reachable to anyone consuming the flake, and `home/` only overrides it rather than holding a literal value.
`home/vscode/hades.nix` is the one file `home/default.nix` does not import, because that VS Code profile exists on hades alone; `hosts/hades.nix` imports it directly.

Every `dotfiles.*` module is off by default, so importing `homeModules.dotfiles` turns nothing on.
Each host file lists every toggle it wants, even where hosts overlap, so reading one file tells you the whole configuration.

OpenRouter has no toggle of its own to set: `dotfiles.openrouter` turns on when `dotfiles.openrouter.apiKeySecret` names a secret, which only `home/` does, and every integration under `modules/openrouter/` follows it.

`hosts/darter.nix` is the shell and secret floor, the dev toolchains and agent CLIs, and fonts, stylix, obsidian, signal, and zed (a display without the desktop session), plus `targets.genericLinux`, its signing key, and the rosequartz KUBECONFIG.
`hosts/hades.nix` is the same floor and toolchains plus the full desktop session, ocaml, dotnet and emacs, its signing key, the LAN-facing omnigent and remote-control toggles, the rosequartz admin identity that makes it own `~/.kube/config` outright, and its desktop package list.
`hosts/server.nix` is `home/account.nix` plus the floor, containers, and kubernetes.
It deliberately does not import the rest of `home/`: the personal layer declares sops secrets encrypted to erik's laptop keys, which a server has no reason to hold.
Server does get oh-my-zsh and Powerlevel10k, because it sets `dotfiles.zsh.enable` and `dotfiles.zsh.ohMyZsh.enable`, and the prompt follows `dotfiles.zsh.enable`.
A headless host that genuinely wants no prompt sets `dotfiles.zsh.p10kConfig = null`.

`modules/` itself stays generic, holding enable toggles and the mechanics needed for a feature to function, with no personal values:

- `ai/` - claude-code, github-copilot-cli, cursor-cli.
  Each MCP integration and third-party service (aws, azure, cloudflare, figma, slack, gossamer, per-language servers, etc.) gets its own `.nix` toggle file; `moer/`, `nix-skill/`, and `tdd-orchestrator/` are skill submodules (a SKILL.md plus agents), following the same one-file-per-concern pattern as the rest of `modules/`.
  `global-context.md` is the user-level agent instructions, rendered to both `~/.claude/CLAUDE.md` and `~/.copilot/copilot-instructions.md`; `.claude/skills/agent-context/` covers how to change it.
  `checkout-root.nix` renders `modules/ai/checkout-root.md` to `~/src/AGENTS.md` with a `CLAUDE.md` include beside it, matching the pairing the repos underneath use, so conventions spanning the whole checkout root are stated once instead of per repo.
  The document is an option, `dotfiles.ai.checkoutRoot.context`, defaulting to the bundled file; a consumer supplies their own or sets it to null to write nothing.
  `omnigent.nix` installs omnigent and runs its server and host daemon; its model provider comes from `openrouter/omnigent.nix`.
  `coderabbit.nix` installs the CodeRabbit CLI from the `mangopkgs` overlay (packaged at `pkgs/coderabbit/` in https://github.com/unmango/pkgs) and turns its self-update off, since `coderabbit update` rewrites the binary in place and a nix-installed one lives in the read-only store.
  Authentication is a rendered `~/.coderabbit/auth.json` (`{"type":"api_key",...}`) rather than an environment variable, because the CLI reads no `CODERABBIT_API_KEY`; its api_key auth branch returns that file verbatim instead of consulting the OS credential store the OAuth branch uses, so the file alone is a complete authenticated state.
  The key comes from `dotfiles.ai.coderabbit.apiKeySecret` naming a `sops.secrets` entry, and the CLI rejects a user API key, so it has to be an agentic one.
- `openrouter/` - OpenRouter as the one provider for every paid model outside Claude Code.
  Claude Code stays on the Claude subscription, since Remote Control refuses an `ANTHROPIC_BASE_URL` other than api.anthropic.com.
  `default.nix` holds the key (`apiKeySecret`, a `sops.secrets` name) and two model tiers (`models.default`, `models.fast`), and exposes read-only `baseUrl`, `apiKeyFile`, and `apiKeyPlaceholder` for integrations to consume.
  Each tool gets one file here declaring `dotfiles.openrouter.<tool>.enable` (on by default) plus a model option defaulting to a tier, active only when both OpenRouter and the tool are enabled.
  Adding a tool means adding a file and listing it in `default.nix`'s `imports`.
  `omnigent.nix` treats `~/.omnigent/config.yaml` as runtime-owned (omnigent generates `host.host_id` there, and `omnigent config set --global` rewrites the whole file), so an activation script yq-assigns only the nix-declared `providers.openrouter` entry into it and leaves every sibling key alone.
  Its `auth_command` reads the key file rather than `OPENROUTER_API_KEY`, since the systemd user unit running the server never sees a login shell.
  `opencode.nix` passes the key as `{file:...}`, which opencode resolves when it loads its config.
  `opencommit.nix` sets `dotfiles.git.openCommit`'s key, provider, and model at `mkDefault`, reusing that module's `~/.opencommit` template.
  `zed.nix` wraps `zeditor` to export `OPENROUTER_API_KEY` from the key file at launch, because Zed has no file route for the key; on macOS, launching Zed.app from Finder bypasses the wrapper.
- `home-manager/` - the `homeup` command, a `home-manager switch` from a local checkout that works from any directory.
  `dotfiles.homeManager.flakePath` names the checkout and is baked into the script, so it needs neither a cwd nor an environment; `configuration` overrides the `$USER@$HOSTNAME` name home-manager infers, and `backupExtension` the `-b hm-backup` it passes.
- `flake-update/` - flake-update automation, switching the same checkout `home-manager/` names (`dotfiles.automation.flakeUpdate.flakePath` defaults to `dotfiles.homeManager.flakePath`)
- `brave/` - Brave
- `launch-services/`: macOS-only, and unreached, since no darwin configuration is defined.
  `launch-services.nix` registers the app bundles under `~/Applications/Home Manager Apps` with Launch Services (`lsregister`, which backs `open -a`, the Dock, and Launchpad) and the Spotlight metadata index (`mdimport`, which backs Cmd+Space) on every activation.
  Home Manager copies the bundles there but tells neither, and rsync writes them with normalized timestamps, so the fsevents that would trigger an automatic reindex do not reliably fire and an app can sit fully installed yet unreachable from every launcher.
  Both commands only refresh an index, so the activation entry warns instead of failing.
  Defaults to on for darwin and evaluates to nothing elsewhere.
- `vscode/`, `vscodium/`, `neovim/` (via nixvim), `zed/`, `helix/`, `emacs/`, `obsidian/` - editors.
  `vscodium/` mirrors `vscode/` over Home Manager's separate `programs.vscodium` (its own `~/.vscode-oss` and `~/.config/VSCodium`), so a host can enable both; only `hosts/generic.nix` does, so the module is built rather than installed anywhere real.
  `neovim/nixvim-config.nix` is the curated LSP and plugin set, imported when `dotfiles.neovim.defaultConfig` is on and exported as `nixvimModules.default` so `packages.nixvim` builds the same configuration standalone.
  `zed/` carries the extension list as the `dotfiles.zed.extensions` default.
- `fonts/` - Nerd Fonts (MesloLGS NF, FiraCode), opt-in via `dotfiles.fonts.enable`
- `gnupg/` - gpg + gpg-agent for signing and encryption only; gpg-agent never serves SSH (see `ssh/`).
  `dotfiles.gnupg.pinentry` picks the passphrase prompt: `pinentry-gnome3` on Linux, `pinentry_mac` on macOS, and `hosts/server.nix` sets `pinentry-curses`.
- `onepassword/` - the 1Password CLI, plus the agent socket when a host sets `dotfiles.ssh.agent = "1password"`, and in that case git signs through the app's `op-ssh-sign`, since 1Password keys never reach `ssh-keygen`.
  The desktop app owns the socket and is not installable from nixpkgs on macOS, so the module points at an app installed by hand rather than installing anything but the CLI.
  No real host enables it; `hosts/generic.nix` does, so both platforms' socket paths are built.
- `zsh/` - zsh, Powerlevel10k, and a framework: oh-my-zsh (`dotfiles.zsh.ohMyZsh.enable`) or prezto (`dotfiles.zsh.prezto.enable`), mutually exclusive by assertion.
  `dotfiles.zsh.enable` is the base shell (aliases, history, completion) plus the prompt; the bundled `.p10k.zsh` sits beside it, and `dotfiles.zsh.p10kConfig` points at it and a consumer can replace or set null.
  `oh-my-zsh/` and `prezto/` are submodules holding each framework's config, each active only alongside `dotfiles.zsh.enable`.
  Every host uses oh-my-zsh; the prezto config is kept, switched off.
- `sops/` - sops-nix age key location (`~/.config/sops/age/keys.txt`).
  Secrets live under `home/secrets/`, encrypted in `.sops.yaml` to erik's darter and hades keys so one file decrypts on both, and to each YubiKey's PIV slot (age-plugin-yubikey) as a backup that needs the key and its PIN.
  `dotfiles.sops.keyFile` holds only the software identities, since sops-nix reads it unattended; YubiKey identities live in `~/.config/sops/age/yubikey.txt` (see `docs/yubikey.md`).
  `rosequartz.yaml` is the exception in origin rather than in handling: the admin cert and key are clan-generated in the nixos repo and re-encrypted here, so a rotation there has to be copied over the same way `modules/kubernetes/rosequartz/ca.crt` does.
- `ssh/` - SSH client config.
  Host aliases come from the `hosts` flake input (https://github.com/UnstoppableMango/hosts).
  The module takes the table as data (`dotfiles.ssh.hosts`, empty by default); `hosts/common.nix` feeds it `inputs.hosts.lib.addresses`, so no module closes over `inputs` for it.
  `HostKeyAlias` plus the `@cert-authority` entry in `~/.ssh/known_hosts_nix` mean cluster machines validate against the clan SSH CA instead of prompting on first connect.
  `dotfiles.ssh.agent` names the one SSH agent a machine uses (`openssh`, `gnome`, `1password`, or null), since every agent claims `SSH_AUTH_SOCK` and all but one would be ignored.
  `gnome` means the system's `gcr-ssh-agent`, which exports nothing, so the module sets `SSH_AUTH_SOCK` through Home Manager's `sshAuthSock`, which covers shells, systemd, and D-Bus.
  hades uses `gnome` so the passphrase-protected key unlocks with the login keyring; darter and server use `openssh`; macOS defaults to null because launchd already runs an agent.
  `dotfiles.ssh.primaryIdentityFile` is the machine's own key, `~/.ssh/id_ed25519` by default and offered first, and `dotfiles.ssh.identityFiles` is the additive list after it, which `modules/yubikey/` fills with each key's FIDO2 credential handle.
  The split exists because a list option keeps only the definitions at the winning override priority, so a host naming its key in `identityFiles` would discard those handles instead of preceding them.
  Both feed one `IdentityFile`, unset when they are empty, because an explicit `IdentityFile` stops ssh from trying its built-in defaults.
  `primaryIdentityFile = null` says the machine's key is somewhere other than the default path without saying where, leaving that to a block in `~/.ssh/config.d/`; darter is the one host that does this.
- `stylix/` - Stylix theming, scoped to terminals only (kitty, ghostty) via `dotfiles.stylix.enable`
- `kitty/`, `ghostty/` - terminals
- `signal/` - Signal, both halves: the desktop app (`dotfiles.signal.desktop`) and `signal-cli` (`dotfiles.signal.cli`), each on by default under `dotfiles.signal.enable`.
  A headless host that wants the CLI alone sets `dotfiles.signal.desktop = false`.
- `c/`, `containers/`, `dotnet/`, `git/`, `go/`, `javascript/`, `kubernetes/`, `nix/`, `ocaml/`, `python/`, `rust/` - per-language dev tooling.
  There is no `tdl/` module: the tdl flake exports its own `homeModules.tdl` declaring `programs.tdl.*` (the CLI plus the VS Code extension), so `homeModules.dotfiles` folds that module in alongside `./modules` and a host sets `programs.tdl.enable`, rather than this repo re-declaring a `dotfiles.tdl` toggle over `pkgs.tdl`.
  `git/signing.nix` signs commits (not tags) with `dotfiles.git.signing.key`, an SSH public key by default, which each host sets for itself; the private half is whatever the host's `dotfiles.ssh.agent` holds.
  `dotfiles.git.signing.allowedSigners` comes from `home/git.nix`, every machine's key, and becomes `gpg.ssh.allowedSignersFile` so a commit signed on one machine verifies on the others.
  A bare key verifies as `user.email`; an `{ email, key }` entry is for a key that signs under another email.
  `git/repos.nix` imports the nix2git home-manager module from https://github.com/unmango/nix2git, whose `nix2git.repositories` runs `git init` for declared paths under the home directory that do not exist yet, and never clones, rewrites, or deletes.
  `kubernetes/` keeps k9s, openshift, and rosequartz submodules.
  `git/opencommit.nix` renders the whole of `~/.opencommit` through `sops.templates` when `dotfiles.git.openCommit.apiKeySecret` names a `sops.secrets` entry, because opencommit skips its defaults entirely once that file exists.
  The file route rather than `OCO_API_KEY` in the environment, since the `prepare-commit-msg` hook also fires for editor and GUI commits that never see a login shell.
  With OpenRouter on, `openrouter/opencommit.nix` supplies the key, provider, and model.
  `kubernetes/rosequartz/` owns the shape of the rosequartz kubeconfig (contexts, VIP, dex OIDC exec block); a host supplies the admin cert and key paths, and omitting them yields the OIDC context alone (which is what darter takes).
  `containers/` installs both stacks side by side: podman (with buildah, skopeo, podman-compose) and `docker-client`, the CLI without the daemon, since a system dockerd is outside Home Manager's reach.
  `docker compose` and `docker buildx` are linked into `~/.docker/cli-plugins` because the CLI resolves subcommands there rather than from PATH.
  `REGISTRY_AUTH_FILE` points podman, skopeo, and buildah at `~/.docker/config.json`, so one `docker login` serves both (`dotfiles.containers.sharedAuth`).
  `dotfiles.containers.podmanSocket` and `.userRegistryConfig` default to `targets.genericLinux.enable`: non-NixOS hosts get the rootless `podman.socket`/`podman.service` user units and `~/.config/containers/{policy.json,registries.conf}`, which the podman package carries no defaults for, while NixOS hosts keep the system layer's units and `/etc/containers` authoritative.
- `gnome/` - the GNOME option, the extension packages, and the derived `enabled-extensions` list.
  The dconf preferences that go with it are taste and live in `home/gnome.nix`.
- `yubikey/` - ykman, yubico-piv-tool, libfido2, and yubikey-personalization, with Yubico Authenticator behind `dotfiles.yubikey.gui` (Linux only), and age-plugin-yubikey when sops is on.
  `dotfiles.yubikey.keys.<name>.sshKey` records each key's resident FIDO2 SSH credential (values in `home/ssh.nix`), and ssh offers the handle `ssh-keygen -K` writes as `~/.ssh/id_ed25519_sk_rk_<name>`.
  `docs/yubikey.md` is the onboarding runbook.
  When gpg is on, scdaemon is set to `disable-ccid` and `pcsc-shared`, so it reaches the key through pcscd without holding it exclusively and ykman keeps working alongside gpg-agent.
  `pcscd` and the udev rules are system services outside Home Manager's reach: the nixos repo supplies them on hades, and darter needs the distribution packages.

Six home configurations are built: `erik@darter`, `erik@hades`, `erik@server`, and `generic@container` on x86_64-linux, plus `generic@x86_64-linux` and `generic@aarch64-darwin`.
No machine is actually named `server`; that entry exists so `hosts/server.nix` is covered by `nix flake check` rather than only breaking whenever someone next touches it.

`generic@x86_64-linux` and `generic@aarch64-darwin` are the same idea one layer out: both build `hosts/generic.nix`, which turns most modules on (brave and gnome on Linux only), imports nothing from `home/`, and sets a throwaway account whose home directory follows the platform, so `homeModules.dotfiles` is built here rather than only breaking in somebody else's flake.
`generic@aarch64-darwin` is also the only consumer of the darwin branches in `modules/` (ghostty's null package, the 1Password agent socket, the containers defaults, omnigent's launchd unit, `launch-services/`).
`nix flake check` does not evaluate `homeConfigurations`, so CI builds them explicitly.
That takes two jobs: `check` on `ubuntu-latest` for the linux configurations, and `darwin` on `macos-latest` (Apple Silicon, so aarch64-darwin) for the darwin one, which gets a real build rather than an evaluation.

`generic@container` builds `hosts/container.nix`, the headless, identity-free configuration behind `packages.container` (x86_64-linux only, defined in `flake.nix`).
It leaves off every GUI module plus 1Password (its agent socket belongs to the desktop app), sops (an image holds no age key), gnupg (pinentry needs a session), and containers (rootless podman does not run inside a container).
It sets `dotfiles.ssh.agent = null`, since the image runs no systemd user manager to host an agent.
It also leaves off neovim, whose curated LSP set bundles every language server, and every agent CLI other than Claude Code (`ai.copilot`, `ai.cursor.cli`, `ai.coderabbit`, `ai.omnigent`, `ai.opencode`).
The `ai.*` integrations that default on but need a display or a toolchain the image lacks (azure, chromeDevtools, playwright, csharp, fsharp, haskell, ocaml) are off too.
For size it also drops the nix, javascript, and kubernetes toolchains, helix, the `home-manager` CLI (the image is never activated or switched), `programs.vim` (Home Manager builds it from `vim-full`), the gitMcp, gossamer, nix, rust, and typescript `ai.*` integrations, and every glibc locale except `en_US.UTF-8`.
The image is built with nix2container.
Activation needs a writable home, so it cannot run at build time; the image copies the activation package's `home-files` tree into `/home/generic` instead, and puts `home.path/bin` on `PATH`.
A third CI job, `image`, builds it on every run and pushes `ghcr.io/unstoppablemango/dotfiles` as `:latest` and `:<short-sha>` from `main` only.

Overlays from multiple inputs (devctl, mangopkgs, nil, nix-direnv, nix-vscode-extensions, tdl) are composed in `flake.nix` and applied to nixpkgs, alongside the local ones from `overlays/`.
`zed.overlays.default` is commented out: nixpkgs' livekit-libwebrtc is out of sync with zed 0.217.3's expected webrtc API (`no type named 'AudioDeviceSink' in namespace 'webrtc'`).

`tdl.overlays.default` composes gomod2nix's overlay in (tdl is built with its `buildGoApplication`), so `buildGoApplication` and `mkGoEnv` land in `pkgs` alongside `tdl` and `vscode-tdl`.
`overlays/` holds the ones that are not a bare re-export of a flake input: `clan.nix` adapts an input's packages, and `vscode.nix` symlinks `node_modules.asar.unpacked` into the built product, without which oniguruma never loads and every file renders untokenized.
It patches vscode and vscodium alike, both being built from the same nixpkgs generic builder.
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
