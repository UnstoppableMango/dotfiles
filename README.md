# UnstoppableMango's dotfiles

[![CI](https://github.com/UnstoppableMango/dotfiles/actions/workflows/ci.yml/badge.svg)](https://github.com/UnstoppableMango/dotfiles/actions/workflows/ci.yml)
[![Last commit](https://img.shields.io/github/last-commit/UnstoppableMango/dotfiles)](https://github.com/UnstoppableMango/dotfiles/commits/main)
[![License: MIT](https://img.shields.io/github/license/UnstoppableMango/dotfiles)](LICENSE)
[![Nix flake](https://img.shields.io/badge/nix-flake-blue?logo=nixos)](flake.nix)

[Nix](https://nixos.org) has consumed my dotfiles.
`main` is not stable, my NixOS system configurations live over at [UnstoppableMango/nixos](https://github.com/UnstoppableMango/nixos).

This repo manages my [Home Manager](https://nix-community.github.io/home-manager/) config with [flake-parts](https://flake.parts/), using the "Dendritic Pattern": modules are grouped by category (browsers, editors, shells, ...) rather than by machine.

## Home configurations

| Configuration | System       |
| ------------- | ------------ |
| `erik@darter` | x86_64-linux |
| `erik@hades`  | x86_64-linux |
| `erik@server` | x86_64-linux |

No machine is named `server`; that entry exists so the headless profile is covered by `nix flake check`.

`erik@hades` is build-only.
Hades' home is activated by the [nixos](https://github.com/UnstoppableMango/nixos) repo through the Home Manager NixOS module, so this entry exists to verify the config evaluates and builds, not to switch into.
Erik's home on hades is installed through the Home Manager NixOS module rather than as a standalone Home Manager install, so it is applied with `nixos-rebuild switch` from the nixos repo, never with `home-manager switch` or `make home`.
`erik@darter` is the standalone configuration.

## Layout

- `modules/` - option-driven software config, no identity
- `home/` - my identity and taste, consuming those options
- `profiles/` - named toggle bundles: `base`, `dev`, `ai`, `graphical`, `workstation`
- `hosts/` - one file per machine, composing profiles

Category modules live under `modules/`:

- `ai/` - Claude Code, GitHub Copilot CLI, Cursor CLI
- `browsers/` - Brave
- `desktop/gnome/` - GNOME
- `editors/` - VS Code, Neovim (nixvim), Zed, Helix, Emacs
- `gnupg/` - gpg + gpg-agent, pinentry on Linux
- `onepassword/` - 1Password CLI, SSH agent socket, and SSH commit signing
- `shells/zsh/` - Zsh (Prezto, or oh-my-zsh via `dotfiles.zsh.ohMyZsh.enable`), Powerlevel10k
- `sops/` - sops-nix age key location for erik
- `terminals/` - Kitty, Ghostty
- `toolchain/` - c, containers, dotnet, git, go, javascript, kubernetes (incl. the rosequartz kubeconfig), nix, ocaml, python

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
