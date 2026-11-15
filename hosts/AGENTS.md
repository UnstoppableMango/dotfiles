# hosts/

Composition only.
A host file lists the modules it turns on, plus what is true of that machine alone (a signing key, a kubeconfig path, a package only it installs).
`flake.nix` pairs `common.nix` with each host file, so every configuration gets the whole option set.

## Rules

- A host lists every toggle it wants, even where hosts overlap, so reading one file shows the whole configuration.
  There is no shared toggle file between real machines.
  The `generic*` configurations exist for build coverage and may layer: `generic-linux.nix` imports `generic.nix`.
- Set no personal values here; they go in `home/`.
- A toggle cannot read the platform from `pkgs`.
  `pkgs` depends on `nixpkgs.overlays`, stylix's overlay reads `config.lib`, and merging `config.lib` forces every module's conditional `lib` definition (Home Manager's rofi under `dotfiles.i3.enable`, for one), so `i3.enable = isLinux` is an infinite recursion.
  Write literal toggles.

## common.nix

- Imports `homeModules.dotfiles` and the stylix, nixvim, and sops-nix modules, once.
- Owns `nixpkgs.overlays`, `nixpkgs.config`, and `nix.package` (see [architecture](../docs/agents/architecture.md#nixpkgs-ownership)).
- Adds the `unstoppablemango` Cachix substituter (see [CI and Cachix](../docs/agents/ci.md)).
- Feeds flake-input data to module options: `dotfiles.ssh.hosts` from `inputs.hosts.lib.addresses`, `dotfiles.ai.mattpocock.src` from `mattpocock-skills`.

## Configurations

| Configuration            | File                | Notes                                                                        |
| ------------------------ | ------------------- | ---------------------------------------------------------------------------- |
| `erik@darter`            | `darter.nix`        | Non-NixOS laptop; `targets.genericLinux`                                     |
| `erik@hades`             | `hades.nix`         | NixOS desktop; imports `home/vscode/hades.nix`                               |
| `erik@server`            | `server.nix`        | No machine has this name; `make build` falls back to it on other Linux boxes |
| `tz@hades`               | `tz-hades.nix`      | Second account on hades; imports nothing from `home/`                        |
| `generic@container`      | `container.nix`     | The `packages.container` image; see [container](../docs/agents/container.md) |
| `generic@x86_64-linux`   | `generic-linux.nix` | `generic.nix` plus the Linux-only desktop modules                            |
| `generic@aarch64-darwin` | `generic.nix`       | The only consumer of the darwin branches in `modules/`                       |

- `darter.nix`: the shell and secret floor, the dev toolchains and agent CLIs, fonts, stylix, obsidian, signal, and zed (a display without the desktop session), plus its signing key and the rosequartz KUBECONFIG.
  Darter is not NixOS, so only `make home` applies there.
- `hades.nix`: the same floor and toolchains plus the full desktop session (GNOME, with i3 and Hyprland beside it at the login screen), ocaml, dotnet, emacs, BizHawk, its signing key, the LAN-facing omnigent and remote-control toggles, the rosequartz admin identity that makes it own `~/.kube/config` outright, and its desktop package list.
  On hades `make system` rebuilds NixOS from the nixos repo, which configures the machine and erik's system account and nothing about his home environment.
- `server.nix`: `home/account.nix` plus the floor, containers, and kubernetes.
  It skips the rest of `home/`, because the personal layer declares sops secrets encrypted to erik's laptop keys, which a server has no reason to hold.
  It gets oh-my-zsh and Powerlevel10k through `dotfiles.zsh.enable` and `dotfiles.zsh.ohMyZsh.enable`; a headless host that wants no prompt sets `dotfiles.zsh.p10kConfig = null`.
- `tz-hades.nix`: the nixos repo creates the account and installs the `home-manager` CLI for it.
- `generic.nix`: turns most modules on, imports nothing from `home/`, and sets a throwaway account whose home directory follows the platform, so `homeModules.dotfiles` is built here rather than first breaking in someone else's flake.
