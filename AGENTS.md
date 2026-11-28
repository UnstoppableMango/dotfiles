# AGENTS.md

A Nix flake (flake-parts plus Home Manager) that manages one user's home environment, `erik`, across several Linux hosts.
The NixOS system configs live in https://github.com/UnstoppableMango/nixos; nothing here configures a system.

## Commands

All tasks go through `make`:

```sh
make check   # nix flake check
make build   # build the home configuration from the local flake
make fmt     # nix fmt (treefmt)
make home    # switch home-manager from this checkout
make graph   # rebuild graphify-out/ after changing .nix files
```

`make check` does not evaluate `homeConfigurations`, so validate a module change with `make build`.
`make build` picks the configuration from `hostname -s` (darter, hades and theia build their own, macOS builds `generic@aarch64-darwin`, any other Linux box builds `erik@server`).
Set `HOME_CONFIG` to build another, for example `make build HOME_CONFIG=erik@hades`.

## Architecture

Three top-level directories, in dependency order.
Each has an `AGENTS.md` with the rules for files in it; read it before adding or moving a file there.

- [`modules/`](modules/AGENTS.md): generic, option-driven software configuration with no identity baked in.
  Declares `dotfiles.*` options; sets no personal values.
- [`home/`](home/AGENTS.md): erik's identity (the account, git email, GNOME dconf, secrets).
  Consumes `dotfiles.*`; declares none.
- [`hosts/`](hosts/AGENTS.md): one file per home configuration, plus `common.nix`, which every configuration is built on.
  The only entrypoints.

The reasoning behind the split is in [docs/agents/architecture.md](docs/agents/architecture.md).

## graphify

When `graphify-out/graph.json` exists, run `graphify query "<question>"` before your first grep, search, or source-file read about this repository, and put this rule in every subagent prompt that explores code.
See [docs/agents/graphify.md](docs/agents/graphify.md) for the other commands and how the graph is built.

## Topic docs

- [Architecture: class vs instance, nixpkgs ownership, flake layout](docs/agents/architecture.md)
- [Overlays and packaging](docs/agents/overlays.md)
- [CI and Cachix](docs/agents/ci.md)
- [The container image (`generic@container`)](docs/agents/container.md)
- Module notes: [ai and openrouter](docs/agents/modules/ai.md), [git](docs/agents/modules/git.md), [ssh, gpg, sops, yubikey, github token](docs/agents/modules/security.md), [desktop](docs/agents/modules/desktop.md), [toolchains](docs/agents/modules/toolchains.md), [shell, editors, and apps](docs/agents/modules/apps.md)
- Runbooks: [github-token](docs/github-token.md), [yubikey](docs/yubikey.md), [i3](docs/i3.md), [hyprland](docs/hyprland.md)
