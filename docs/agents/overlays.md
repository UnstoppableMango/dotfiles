# Overlays and packaging

`overlay.nix` composes the overlays from inputs (devctl, mangopkgs, nil, nix-direnv, nix-vscode-extensions, tdl) with the local ones from `overlays/`, and `hosts/common.nix` applies the result.

- `tdl.overlays.default` composes gomod2nix's overlay in (tdl is built with its `buildGoApplication`), so `buildGoApplication` and `mkGoEnv` land in `pkgs` alongside `tdl` and `vscode-tdl`.
- `overlays/clan.nix` and `overlays/slip.nix` lift a package out of an input that exports no overlay (`clan-core` and `slip`).
- `overlays/claude-code.nix` overrides nixpkgs' claude-code with a newer release by pointing its `manifest` argument at `overlays/claude-code-manifest.zst.json`, a copy of `https://downloads.claude.ai/claude-code-releases/<version>/manifest.zst.json`.
  nixpkgs tracks the CLI a few releases behind, and the model list is baked into the binary, so a model newer than the packaged release is unreachable until the manifest moves.
  Refresh it by downloading the manifest for the wanted version; the derivation takes the version and the per-platform checksums from that file.
- Software with no nixpkgs package and no upstream flake is packaged in https://github.com/unmango/pkgs and arrives through the `mangopkgs` overlay.

## Dev shell

The dev shell (`direnv allow` or `nix develop`) carries the tools `make` calls.
Its graphify is `inputs'.mangopkgs.packages.graphify.withGrammars` with nixpkgs' `tree-sitter-nix`: graphify reads `.nix` files only through a patch in https://github.com/unmango/pkgs, and only when that grammar is installed.
