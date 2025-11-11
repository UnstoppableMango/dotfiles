# UnstoppableMango's dotfiles

My most recent obsession is [Nix](https://nixos.org), and it has consumed my dotfiles.

At the time of writing, all of my configuration is [in a single file](./hosts/hades/configuration.nix).
The [flake](./flake.nix) is fairly fleshed out.
I'll modularize things better when the mood strikes.

## Development

Run flake checks

```shell
$ make check
nix flake check
```

Update flake inputs

```shell
$ make update
nix flake update
```

Run checks automatically while working

```shell
$ make watch
watchexec -e nix nix flake check
[Running: nix flake check]
[Command was successful]
```

```shell
$ export WATCHEXEC=/path/to/watchexec
$ make watch
/path/to/watchexec -e nix nix flake check
[Running: nix flake check]
[Command was successful]
```

Build the toplevel

```shell
$ make
nix build .#nixosConfigurations.hades.config.system.build.toplevel
```

## References and Links

- <https://github.com/brenno263/nix-config>
- <https://github.com/grey-lovelace/nixos-config>
- <https://github.com/BenMcH/dotfiles/tree/main/home-manager/dot-config/home-manager>
- <https://nixos-and-flakes.thiscute.world>
