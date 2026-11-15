# CI and Cachix

## CI

`.github/workflows/ci.yml` runs three jobs:

- `check`, on the self-hosted `thecluster` runner: `nix flake check --all-systems`, then builds of `erik@darter` and `generic@x86_64-linux`, since `nix flake check` does not evaluate `homeConfigurations`.
  CI builds no other x86_64-linux home configuration.
- `darwin`, on `macos-latest` (Apple Silicon): a real build of `generic@aarch64-darwin`.
- `image`: builds `packages.container` on every run and pushes `ghcr.io/unstoppablemango/dotfiles` as `:latest` and `:<short-sha>` from `main` only.

## Cachix

CI pushes to the `unstoppablemango` Cachix cache.
`hosts/common.nix` adds it as a substituter for every configuration, so a local build after CI has run fetches rather than compiles.
That matters most for `mangopkgs` packages: cache.nixos.org carries nothing outside nixpkgs, so without this cache each version bump of one is a from-source build on every machine.

A user's nix.conf reaches a substituter only with the system's permission, and silently substitutes nothing without it.
A host that compiles anyway is missing one of two things in its system nix.conf:

- the cache URL in `trusted-substituters` plus its signing key in `trusted-public-keys`, which authorizes that one cache (preferred); or
- the user in `trusted-users`, which authorizes any cache they name.
  Nix's manual warns that this "is essentially equivalent to giving that user root access to the system".
