# UnstoppableMango's dotfiles

My most recent obsession is [Nix](https://nixos.org).

At the time of writing, all of the configuration is [in a single file](./hosts/hades/configuration.nix).
I'll modularize it if the mood strikes.

## Development

```shell
$ make
nix build .#nixosConfigurations.hades.config.system.build.toplevel
```

```shell
$ make check
nix flake check
```

```shell
$ make update
nix flake update
```

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

## References and Links

- <https://github.com/brenno263/nix-config>
- <https://github.com/grey-lovelace/nixos-config>
- <https://github.com/BenMcH/dotfiles/tree/main/home-manager/dot-config/home-manager>
- <https://nixos-and-flakes.thiscute.world>
