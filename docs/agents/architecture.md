# Architecture

## Class vs instance

Every file falls into one of two buckets.
`modules/` is the class bucket: it describes how a piece of software is configured, mechanically, with no identity baked in.
`home/` is the instance bucket: it holds this person's actual values.
`hosts/` holds no personal values, only composition.

An opinionated value is not automatically identity.
A curated set that any consumer of this flake would plausibly want belongs in `modules/` as an option default rather than as a literal in `home/`.
The test is whether the next person would have to change the value, and whether no toggle already exists for saying so.
"Did someone choose this?" is the wrong question.

Before adding or moving a file:

1. Would a different person using this flake want a different value here?
   If yes, it is an instance and belongs under `home/`.
   If everyone would want the same mechanism, it is a class and belongs under `modules/`.
2. Does the file hardcode a literal (an email, a color hex, a hostname, an API key path, one person's editor choice)?
   That literal belongs in `home/`, or the class module needs an option that `home/` supplies.
3. Is it an `enable` toggle rather than a value?
   Set it in each host file that wants it.
4. Is a module accreting config for one sub-tool?
   Split it into a submodule directory.
5. Would the value differ between machines?
   It goes in `hosts/<machine>.nix`.

## No shared-identity layer

This repo configures one identity, so a "shared across identities" layer would be an abstraction over a set of size one; its contents live in `home/`.
A second identity lives in its own flake and consumes `homeModules.dotfiles`, supplying its own toggles, account, secrets, and (on macOS) nix-darwin system layer.
The reusable half of a shared layer therefore belongs in `modules/` behind options: the export is the sharing mechanism.

The account is identity rather than a class of machine, so it sits in `home/account.nix`.

Precedent: the sops key path and the rosequartz kubeconfig describe erik's user environment rather than a clan machine, so they live in `modules/sops/` and `modules/kubernetes/rosequartz/` rather than in the nixos repo's `machines/hades/configuration.nix`.
The clan-generated CA and admin cert/key are vendored in (`modules/kubernetes/rosequartz/ca.crt` and `home/secrets/rosequartz.yaml`) rather than reached for across repos.

## No category layer

`modules/` is flat because deciding whether git is a `toolchain/` or a top-level concern, or whether kitty is `terminals/` or part of the shell setup, has no correct answer and gets a different answer each time.
Since `modules/default.nix` reads directories from disk, dropping a directory in enables its options repo-wide, which is the tradeoff for not maintaining a list.

## Flake layout

`homeModules.dotfiles` is `./modules` plus `nix2git.homeModules.nix2git` and `tdl.homeModules.tdl`.
Those two are folded in for opposite reasons: tdl declares the `programs.tdl.*` options this repo deliberately does not re-declare, while nix2git declares `nix2git.repositories`, which `modules/slip/` writes to, so the option has to exist wherever `./modules` does.
`nixvimModules.default` exports `modules/neovim/nixvim-config.nix`, so `packages.nixvim` builds the same configuration standalone.

## nixpkgs ownership

Whoever creates the nixpkgs instance owns `nixpkgs.overlays` and `nixpkgs.config`, and for a standalone home configuration that is the configuration itself.
`hosts/common.nix` supplies both, once, so nothing under `modules/`, `home/`, or the per-configuration host files sets them.
That keeps the tree composable into someone else's Home Manager NixOS module, where `useGlobalPkgs = true` hands ownership to the system and Home Manager warns that any `nixpkgs.*` set inside the home configuration is ignored.

`nix.package` follows the same rule.
Home Manager needs a non-null one to render a nix.conf at all, and a package is not a mergeable value, so naming it in two modules is a conflict rather than a merge (its null default occupies the rung below `mkOptionDefault`).
`hosts/common.nix` names it once; modules that write `nix.settings` (`modules/zed/`, the Cachix substituter) leave it alone.
A consumer taking `homeModules.dotfiles` without `common.nix` sets it themselves.

## Switching and updates

Both `make build` and `make home` act on the local flake, so a switch applies the working tree and the active home matches the checkout.
Input updates stay deliberate: `make update` bumps `flake.lock`, and that lands as a commit.
`make system` runs `nix flake update` and `nixos-rebuild switch` against `/etc/nixos` (the nixos repo), with sudo.
That repo consumes this flake only for `overlays.default` and the dev shell.
