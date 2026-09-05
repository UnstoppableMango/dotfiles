# UnstoppableMango's dotfiles

[![CI](https://github.com/UnstoppableMango/dotfiles/actions/workflows/ci.yml/badge.svg)](https://github.com/UnstoppableMango/dotfiles/actions/workflows/ci.yml)
[![Last commit](https://img.shields.io/github/last-commit/UnstoppableMango/dotfiles)](https://github.com/UnstoppableMango/dotfiles/commits/main)
[![License: MIT](https://img.shields.io/github/license/UnstoppableMango/dotfiles)](LICENSE)
[![Nix flake](https://img.shields.io/badge/nix-flake-blue?logo=nixos)](flake.nix)

[Nix](https://nixos.org) has consumed my dotfiles.
`main` is not stable, my NixOS system configurations live over at [UnstoppableMango/nixos](https://github.com/UnstoppableMango/nixos).

This repo manages my [Home Manager](https://nix-community.github.io/home-manager/) config with [flake-parts](https://flake.parts/), using the "Dendritic Pattern": modules are grouped by category (browsers, editors, shells, ...) rather than by machine.

## Home configurations

| Configuration            | System         |
| ------------------------ | -------------- |
| `erik@darter`            | x86_64-linux   |
| `erik@hades`             | x86_64-linux   |
| `erik@server`            | x86_64-linux   |
| `generic@x86_64-linux`   | x86_64-linux   |
| `generic@aarch64-darwin` | aarch64-darwin |

No machine is named `server`; that entry exists so the headless profile is covered by `nix flake check`.
Neither is any machine or person named `generic`.
Those two build the profiles with no identity attached, so the exports below stay working for somebody who is not me instead of only breaking in their flake.

`erik@hades` is build-only.
Hades' home is activated by the [nixos](https://github.com/UnstoppableMango/nixos) repo through the Home Manager NixOS module, so this entry exists to verify the config evaluates and builds, not to switch into.
Erik's home on hades is installed through the Home Manager NixOS module rather than as a standalone Home Manager install, so it is applied with `nixos-rebuild switch` from the nixos repo, never with `home-manager switch` or `make home`.
`erik@darter` is the standalone configuration.

## Layout

- `modules/` - option-driven software config, no identity
- `home/` - my identity and taste (including the account), consuming those options
- `profiles/` - enable toggles only, bundled by machine class: `base`, `dev`, `ai`, `graphical`, `workstation`
- `hosts/` - one file per machine, composing profiles

`modules/` is flat: one directory per piece of software, each with a `default.nix`, imported by existing rather than by being listed.

- `ai/` - Claude Code, GitHub Copilot CLI, Cursor CLI, and the per-service MCP toggles
- `brave/`, `obsidian/` - browser and notes
- `vscode/`, `neovim/` (nixvim), `zed/`, `helix/`, `emacs/` - editors
- `kitty/`, `ghostty/` - terminals
- `zsh/` - Prezto and Powerlevel10k, or oh-my-zsh via `dotfiles.zsh.ohMyZsh.enable`
- `git/`, `gnupg/`, `onepassword/`, `sops/`, `ssh/` - identity and secret plumbing
- `c/`, `containers/`, `dotnet/`, `go/`, `javascript/`, `kubernetes/`, `nix/`, `ocaml/`, `python/`, `rust/` - language toolchains
- `gnome/`, `fonts/`, `stylix/` - desktop, fonts, theming
- `flake-update/`, `launch-services/` - automation, and macOS Launch Services registration
- `profile/` - singular, not to be confused with the top-level `profiles/` above. `dotfiles.profile.*`, erik's per-tool taste toggles; read by `kitty/`, `kubernetes/k9s/`, `zed/`, and `ai/checkout-root.nix` to decide whether to layer erik's curated values on top of their defaults

## Consuming from another flake

The modules and profiles carry no identity, so another person can build a home configuration out of them.
Add this repo as an input and compose `homeModules.{base,dev,ai,graphical,workstation}` with your own account:

```nix
{
  inputs.dotfiles.url = "github:UnstoppableMango/dotfiles";

  outputs =
    { nixpkgs, home-manager, dotfiles, ... }@inputs:
    {
      homeConfigurations."you@yourmachine" = home-manager.lib.homeManagerConfiguration {
        pkgs = nixpkgs.legacyPackages.aarch64-darwin;
        modules = [
          # `pkgs.gossamer` is referenced by modules/zed and the nixvim
          # config, so the overlay is not optional.
          {
            nixpkgs.overlays = [ dotfiles.overlays.default ];
            nixpkgs.config.allowUnfree = true;
          }

          # These four are what the `dotfiles.*` options build on.
          inputs.stylix.homeModules.stylix
          inputs.nixvim.homeModules.nixvim
          inputs.sops-nix.homeManagerModules.sops
          inputs.nix2git.homeModules.nix2git

          # `base` imports ./modules, so it is the only one you strictly need.
          dotfiles.homeModules.base
          dotfiles.homeModules.dev

          {
            home.username = "you";
            home.homeDirectory = "/Users/you";
            home.stateVersion = "25.05";
          }
        ];
      };
    };
}
```

A profile sets its toggles at normal priority, so turning one back off takes `lib.mkForce` (`dotfiles.gnupg.enable = lib.mkForce false;`) rather than a plain `false`, which is a conflict.
`homeModules.dotfiles` is the raw option set if you would rather pick toggles yourself than take a profile.
`homeModules.taste` is the one piece of `home/` that is published: it flips the four `dotfiles.profile.<tool>.enable` toggles (kitty colors, the k9s skin, zed settings, the ai checkout-root doc), which carry no identity of their own. Those toggles live in `modules/profile/`, so they are already reachable through `homeModules.dotfiles`; a consumer who wants only one piece of the taste can set a single toggle directly instead of importing `homeModules.taste`.
`homeModules.hades` and everything else under `home/` and `hosts/` are my identity and my machines; they are not meant to be consumed.

Defaults that are mine rather than everyone's, and that you will probably want to override:

| Option                             | Default                                     |
| ---------------------------------- | ------------------------------------------- |
| `dotfiles.ssh.hosts`               | `{}`, fed `inputs.hosts.lib.addresses` here |
| `dotfiles.ssh.hostKeyAliasDomain`  | `thecluster.io`                             |
| `dotfiles.ssh.certAuthorities`     | the clan SSH CA public key                  |
| `dotfiles.kubernetes.rosequartz.*` | my cluster's VIP, CA, and OIDC issuer       |
| `dotfiles.neovim.defaultConfig`    | `true`, the bundled nixvim config           |
| `dotfiles.zsh.p10kConfig`          | the bundled `.p10k.zsh`                     |
| `dotfiles.zed.extensions`          | the bundled extension list                  |

`profiles/ai.nix` points omnigent at a sops secret named `openrouter-api-key`, and the module asserts that the name resolves.
Declare it, or set `dotfiles.ai.omnigent.openRouter.enable = false`.

## Development

`make` targets save some typing:

```shell
$ make check   # nix flake check
$ make build   # home-manager build --flake $PWD
$ make fmt     # nix fmt (nixfmt + prettier via treefmt)
$ make watch   # rerun `nix flake check` on file changes
$ make update  # nix flake update
$ make home    # update + switch ~/.config/home-manager
$ make system  # update + rebuild /etc/nixos (needs sudo)
```

Note: `make build` validates the local flake (`$PWD`); `make home` operates on the installed config at `~/.config/home-manager`.

Overridable variables: `NIX`, `HOMEMANAGER`, `WATCHEXEC` (all have defaults).

CI runs `nix flake check --all-systems`, then builds the `erik@darter` home configuration, using the `unstoppablemango` [Cachix](https://www.cachix.org/) cache.

## References and Links

- <https://github.com/brenno263/nix-config>
- <https://github.com/grey-lovelace/nixos-config>
- <https://github.com/BenMcH/dotfiles/tree/main/home-manager/dot-config/home-manager>
- <https://nixos-and-flakes.thiscute.world>
- <https://github.com/nmasur/dotfiles>
- <https://flake.parts/>
- <https://nix-community.github.io/home-manager/index.xhtml>
- <https://github.com/nocoolnametom/nix-config>
- <https://gitlab.com/Zaney/zaneyos>

### Dendritic Pattern

- <https://discourse.nixos.org/t/dendrix-dendritic-nix-configurations-distribution/65853>
- <https://github.com/vic/dendrix>
- <https://github.com/mightyiam/dendritic>
- <https://vic.github.io/dendrix/Dendritic.html>
- <https://github.com/mightyiam/infra/commit/b45e9e13759017fe18950ccc3b6deee2347e9175>
