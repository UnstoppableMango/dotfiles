# AGENTS.md

This file provides guidance to AI agents when working with code in this repository.

## Overview

This is a Nix-based dotfiles repository using Home Manager and flake-parts.
It manages the home configuration for one user, `erik`, across several Linux
hosts.
Four top-level directories, in dependency order:

- `modules/` - generic, reusable, option-driven software configuration, with no
  identity baked in. Declares `dotfiles.*` options; sets no personal values.
- `home/` - erik's identity and taste: the account itself, git email, editor
  LSP/plugin choices, terminal colors, GNOME dconf, secrets. Consumes
  `dotfiles.*`; declares none.
- `profiles/` - named bundles of enable toggles (`base`, `dev`, `ai`,
  `graphical`, `workstation`). Only which modules a class of machine turns on,
  never what they are set to.
- `hosts/` - one file per machine (`darter`, `hades`, `server`). The only
  entrypoints. Each imports the profiles it wants plus whatever is true of that
  machine alone.

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
`home/` is the instance bucket: it holds this person's actual values, and every
file in it is gated on the `dotfiles.*` option its module declares, so importing
it costs nothing on a host that has the feature switched off.
`profiles/` and `hosts/` hold no personal values, only composition: a profile is
enable toggles and nothing else, saying which modules a class of machine turns
on, and a host says which profiles it is plus what is true of it alone (a
signing key, a kubeconfig path, a package it alone installs).
The account (`home.username`, `homeDirectory`, `stateVersion`) is identity, not
a class of machine, so it sits in `home/account.nix`; `hosts/server.nix` imports
that one file directly because it takes the account without the rest of the
personal layer.

An opinionated value is not automatically identity.
A curated set that any consumer of this flake would plausibly want (the nixvim
LSP and plugin list, the Powerlevel10k prompt config, the Zed extension list)
belongs in `modules/` as an **option default**, not as a literal in `home/`.
`home/` keeps only what a second person would definitely want different: the
git email, kitty colors, the GNOME dconf tree, the k9s skin, and the secrets.
The test is not "did someone choose this?" but "would the next person have to
change it?"

Before adding or moving a file, run this checklist:

1. Would a different person using this flake want a different value here? If
   yes, it is an instance and belongs under `home/`. If everyone would want the
   same mechanism, it is a class and belongs under `modules/`.
2. Does the file hardcode a literal (an email, a color hex, a hostname, an
   API key path, "this person's" editor choice)? That literal belongs in
   `home/`, or the class module needs to grow an option that `home/` supplies.
3. Is it an `enable` toggle rather than a value? Toggles belong in `profiles/`,
   grouped by the kind of machine that wants them, not in `home/`. If no
   existing profile fits and more than one host would want the group, add a
   profile; if exactly one host wants it, set it in that host file.
4. Is a module accreting config specific to one sub-tool (more than one or
   two files for it)? Split it into its own submodule directory with a
   `default.nix`, aggregated by the parent, rather than letting the parent
   module grow multiple unrelated concerns.
5. Would the value differ between machines? It goes in `hosts/<machine>.nix`,
   never as a per-host branch inside a class module.

Signals that a change is about to cause drift: hardcoding a literal inside
`modules/`; declaring a `dotfiles.*` option outside `modules/`; a host file
that sets a value rather than composing profiles; or a profile that sets
anything other than toggles.

There is deliberately no "shared across identities" layer. This repo had one
when it also configured a second identity (`erasmussen`, on macOS). With that
identity gone, `users/shared/` was an abstraction over a set of size one, and
its contents now live in `home/`.

A second identity does not come back here. It lives in its own flake and
consumes `homeModules.dotfiles` and `homeModules.{base,dev,ai,graphical,workstation}`, supplying its own
account, secrets, and (on macOS) nix-darwin system layer. That is why the
reusable half of the old `users/shared/` ended up in `modules/` behind options
rather than in a new shared directory: an export is the sharing mechanism, so
the layer is unnecessary. `home/` therefore stays flat rather than becoming
`home/<name>/`, and `profiles/` is unaffected either way, because a profile
never held an identity in the first place.

Precedent: the sops key path and the rosequartz kubeconfig describe erik's
user environment, not a clan machine, so they moved out of the nixos repo's
`machines/hades/configuration.nix` into `modules/sops/` and
`modules/kubernetes/rosequartz/`, with only the clan-generated CA
and admin cert/key paths staying host-specific data supplied from outside.
The `kubernetes/` module itself grew `k9s/`, `openshift/`, and
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
So nothing under `modules/`, `home/`, `profiles/`, or `hosts/` sets them.
`flake.nix`'s `common` list supplies both to the standalone configurations, and the nixos repo supplies them to hades.

`make build` builds the current host's configuration, resolved as `$USER@$(hostname -s)`.
Set `HOME_CONFIG` to build a different one, e.g. `make build HOME_CONFIG=erik@hades`.

Environment variables: `NIX`, `HOMEMANAGER`, `WATCHEXEC`, `HOME_CONFIG` (all have defaults).

CI runs `nix flake check --all-systems` then builds the `erik@darter` home configuration.

## Architecture

The flake uses `flake-parts`.
`modules/` is flat: one directory per piece of software, each with a
`default.nix`. There is no category layer, because deciding whether git was a
`toolchain/` or a top-level concern, or whether kitty was `terminals/` or part
of the shell setup, was a question with no correct answer and a different answer
each time.
`modules/default.nix` imports every subdirectory that has a `default.nix`, read
from disk rather than listed, so adding a module is creating the directory and
nothing else. Dropping a directory in there enables its options repo-wide, which
is the tradeoff for not maintaining a list.
`profiles/base.nix` imports `../modules` once, so every host gets the whole
option set. Everything is `mkIf`-gated, so importing a module a host does not
use costs nothing.

`home/default.nix` collects erik's personal config: git identity/aliases, kitty
colors, vscode's default-profile settings, k9s's skin, GNOME dconf taste, the
`~/src` checkout-root document, and the sops secrets.
The nixvim configuration, the prezto/p10k setup, and the Zed extension list
used to sit here too; they are option defaults in `modules/neovim`,
`modules/zsh/prezto`, and `modules/zed` now, reachable to anyone consuming the
flake and overridable through `dotfiles.neovim.defaultConfig`,
`dotfiles.zsh.p10kConfig`, and `dotfiles.zed.extensions`.
`home/vscode/hades.nix` is the one file `home/default.nix` does not import,
because that VS Code profile exists on hades alone; `hosts/hades.nix` imports it
directly.

The profiles are:

- `base` - Home Manager managing itself, the git/gnupg/nix/sops/ssh/zsh floor,
  and the small CLI tools no machine is usable without. Imports `../modules`.
  Every host takes it.
- `dev` - language toolchains and neovim (c, containers, go, javascript,
  kubernetes, python).
- `ai` - the agent CLIs and the omnigent OpenRouter wiring. Split from `dev`
  because omnigent needs a decryptable secret not every host holds.
- `graphical` - fonts, stylix, obsidian: the floor once a display exists.
- `workstation` - imports `graphical` and adds the full desktop session
  (gnome, brave, vscode, zed, helix, kitty, ghostty).

`hosts/darter.nix` is `base + dev + ai + graphical` plus `targets.genericLinux`,
its signing key, and the rosequartz KUBECONFIG.
`hosts/hades.nix` is `base + dev + ai + workstation` plus its signing key, ocaml
and dotnet, and its desktop package list.
`hosts/server.nix` is `home/account.nix` plus `base`, containers, and
kubernetes. It deliberately does not import the rest of `home/`: the personal
layer declares sops secrets encrypted to erik's laptop keys, which a server has
no reason to hold.
Server does get prezto and Powerlevel10k, because `base` sets
`dotfiles.zsh.enable` and that toggle is the prezto toggle. It used to get a
bare zsh instead, but only because prezto happened to live in `home/`, which
server skips. That was an accident of layering rather than a decision about
headless machines, and it went away when prezto moved into `modules/`. A
headless host that genuinely wants no prompt sets
`dotfiles.zsh.p10kConfig = null`.

`modules/` itself stays generic — enable toggles and the mechanics needed for
a feature to function, with no personal values:

- `ai/` — claude-code, github-copilot-cli, cursor-cli.
  Each MCP integration and third-party service (aws, azure, cloudflare, figma,
  slack, gossamer, per-language servers, etc.) gets its own `.nix` toggle file;
  `moer/`, `nix-skill/`, and `tdd-orchestrator/` are skill submodules (a SKILL.md
  plus agents), following the same one-file-per-concern pattern as the rest of
  `modules/`.
  `global-context.md` is the user-level agent instructions, rendered to both `~/.claude/CLAUDE.md` and `~/.copilot/copilot-instructions.md`; `.claude/skills/agent-context/` covers how to change it.
  `checkout-root.nix` renders `home/checkout-root.md` to `~/src/AGENTS.md` with a `CLAUDE.md` include beside it, matching the pairing the repos underneath use, so conventions spanning the whole checkout root are stated once instead of per repo.
  The module takes the document as an option (`dotfiles.ai.checkoutRoot.context`, null by default) and holds no content itself, so nothing in `modules/` assumes a checkout root exists.
  `omnigent.nix` treats `~/.omnigent/config.yaml` as runtime-owned (omnigent generates `host.host_id` there, and `omnigent config set --global` rewrites the whole file), so an activation script yq-assigns only the nix-declared `providers.openrouter` entry into it and leaves every sibling key alone.
  The OpenRouter key reaches that entry through an `auth_command` reading a `sops.secrets` path rather than `OPENROUTER_API_KEY` in the environment, since the systemd user unit running the server never sees a login shell (the same reasoning as `git/opencommit.nix`).
- `flake-update/` — flake-update automation
- `brave/` — Brave
- `launch-services/`: macOS-only, currently unreached — no darwin configuration is defined.
  `launch-services.nix` registers the app bundles under `~/Applications/Home Manager Apps` with Launch Services (`lsregister`, which backs `open -a`, the Dock, and Launchpad) and the Spotlight metadata index (`mdimport`, which backs Cmd+Space) on every activation.
  Home Manager copies the bundles there but tells neither, and rsync writes them with normalized timestamps, so the fsevents that would trigger an automatic reindex do not reliably fire and an app can sit fully installed yet unreachable from every launcher.
  Both commands only refresh an index, so the activation entry warns instead of failing.
  Defaults to on for darwin and evaluates to nothing elsewhere.
- `vscode/`, `neovim/` (via nixvim), `zed/`, `helix/`, `emacs/`, `obsidian/` — editors.
  `neovim/nixvim-config.nix` is the curated LSP and plugin set, imported when
  `dotfiles.neovim.defaultConfig` is on and exported as `nixvimModules.default`
  so `packages.nixvim` builds the same configuration standalone.
  `zed/` carries the extension list as the `dotfiles.zed.extensions` default.
- `fonts/` — Nerd Fonts (MesloLGS NF, FiraCode), opt-in via `dotfiles.fonts.enable`
- `gnupg/` — gpg + gpg-agent (pinentry only on Linux, so macOS has no way to prompt for a passphrase and does not enable this module)
- `onepassword/` — 1Password CLI, the SSH agent socket, and SSH-format git commit signing through `op-ssh-sign`.
  The desktop app owns both the socket and the signing helper and is not installable from nixpkgs on macOS, so the module configures an app installed by hand rather than installing anything but the CLI.
  `dotfiles.onePassword.signingKey` takes the public half of the key as identity data from `home/`; the module holds no key material.
  Its SSH agent is exclusive with gpg-agent's `enableSshSupport` (both claim `SSH_AUTH_SOCK`), and an assertion fails the build on the overlap instead of letting it show up as a key that never offers itself.
- `zsh/` — Prezto, or oh-my-zsh as an alt via `dotfiles.zsh.ohMyZsh.enable`;
  Powerlevel10k. `prezto/` is a submodule holding the framework config and the
  bundled `.p10k.zsh`, which `dotfiles.zsh.p10kConfig` points at and a consumer
  can replace or set null. Both submodules follow `dotfiles.zsh.enable`, so a
  host that turns zsh on gets a framework rather than a bare shell.
- `sops/` - sops-nix age key location (`~/.config/sops/age/keys.txt`).
  Secrets live under `home/secrets/`, encrypted in `.sops.yaml` to erik's darter and hades keys so one file decrypts on both; hades also decrypts clan-generated material from the nixos repo.
- `ssh/` — SSH client config.
  Host aliases come from the `hosts` flake input (https://github.com/UnstoppableMango/hosts).
  The module takes the table as data (`dotfiles.ssh.hosts`, empty by default); `flake.nix` feeds it `inputs.hosts.lib.addresses`, so no module closes over `inputs` for it.
  Anything importing `homeModules.erik` from outside this flake has to set it too, which the nixos repo does in `machines/hades/configuration.nix`.
  That repo reads the same input for its `internet` clan service, so the two can't drift.
  `HostKeyAlias` plus the `@cert-authority` entry in `~/.ssh/known_hosts_nix` mean cluster machines validate against the clan SSH CA instead of prompting on first connect.
  Agent handling belongs to gnupg's gpg-agent, not here.
- `stylix/` — Stylix theming, scoped to terminals only (kitty, ghostty) via `dotfiles.stylix.enable`
- `kitty/`, `ghostty/` — terminals
- `c/`, `containers/`, `dotnet/`, `git/`, `go/`, `javascript/`, `kubernetes/`, `nix/`, `ocaml/`, `python/`, `rust/` — per-language dev tooling.
  `git/repos.nix` imports the nix2git home-manager module from https://gitlab.com/unmango/nix/2git, whose `nix2git.repositories` runs `git init` for declared paths under the home directory that do not exist yet, and never clones, rewrites, or deletes.
  `kubernetes/` keeps k9s, openshift, and rosequartz submodules.
  `git/opencommit.nix` renders the whole of `~/.opencommit` through `sops.templates` when `dotfiles.git.openCommit.apiKeySecret` names a `sops.secrets` entry, because opencommit skips its own defaults entirely once that file exists.
  The file route rather than `OCO_API_KEY` in the environment, since the `prepare-commit-msg` hook also fires for editor and GUI commits that never see a login shell.
  `kubernetes/rosequartz/` owns the shape of the rosequartz kubeconfig (contexts, VIP, dex OIDC exec block); the nixos repo supplies only the clan-generated CA and admin cert/key paths.
  `containers/` installs both stacks side by side: podman (with buildah, skopeo, podman-compose) and `docker-client`, the CLI without the daemon, since a system dockerd is outside Home Manager's reach.
  `docker compose` and `docker buildx` are linked into `~/.docker/cli-plugins` because the CLI resolves subcommands there rather than from PATH.
  `REGISTRY_AUTH_FILE` points podman, skopeo, and buildah at `~/.docker/config.json`, so one `docker login` serves both (`dotfiles.containers.sharedAuth`).
  `dotfiles.containers.podmanSocket` and `.userRegistryConfig` default to `targets.genericLinux.enable`: non-NixOS hosts get the rootless `podman.socket`/`podman.service` user units and `~/.config/containers/{policy.json,registries.conf}`, which the podman package carries no defaults for, while NixOS hosts keep the system layer's units and `/etc/containers` authoritative.
- `gnome/` — the GNOME option, the extension packages, and the derived
  `enabled-extensions` list. The dconf preferences that go with it are taste and
  live in `home/gnome.nix`.

Five home configurations are built: `erik@darter`, `erik@hades`, and
`erik@server` on x86_64-linux, plus `generic@x86_64-linux` and
`generic@aarch64-darwin`.
No machine is actually named `server`; that entry exists so `hosts/server.nix`
is covered by `nix flake check` rather than only breaking in whatever flake
consumes `homeModules.server`.

The two `generic@*` entries are the same idea one layer out: profiles only, no
`home/`, and an inline account with a throwaway username, so the
`homeModules.{base,dev,ai,graphical,workstation}` exports are built here rather than only breaking in
somebody else's flake. `generic@aarch64-darwin` is also the only consumer the
darwin branches in `modules/` (ghostty's null package, the 1Password agent
socket, the containers defaults, omnigent's launchd unit, `launch-services/`)
have had since the darwin host was removed.
`nix flake check` does not evaluate `homeConfigurations`, so CI builds them
explicitly. That takes two jobs: `check` on `ubuntu-latest` for the linux
configurations, and `darwin` on `macos-latest` (Apple Silicon, so
aarch64-darwin) for the darwin one, which gets a real build rather than an
evaluation.

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
