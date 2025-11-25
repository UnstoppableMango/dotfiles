# UnstoppableMango's dotfiles

[Nix](https://nixos.org) has consumed my dotfiles.
`main` is not stable, my NixOS configurations live over at <https://github.com/Unstoppablemango/nixos>.

## Development

There are some `make` targets that can save you typing like, 5 keystrokes and my repos _need_ a Makefile.

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

## References and Links

- <https://github.com/brenno263/nix-config>
- <https://github.com/grey-lovelace/nixos-config>
- <https://github.com/BenMcH/dotfiles/tree/main/home-manager/dot-config/home-manager>
- <https://nixos-and-flakes.thiscute.world>
- <https://github.com/nmasur/dotfiles>
- <https://flake.parts/>
- <https://nix-community.github.io/home-manager/index.xhtml>
- <https://github.com/nocoolnametom/nix-config>
