---
name: nix
description: Idioms and conventions for writing or reviewing Nix code (flakes, home-manager modules, NixOS modules, packages, overlays). Use when writing, editing, or reviewing .nix files, flake.nix, or home-manager/NixOS module options.
---

# Nix conventions

Prefer `inherit (foo) bar;` over `bar = foo.bar;`.

Reference flake `inputs` only inside `flake.nix`.
The same goes for the `self` argument.
Everything else (home-manager modules, NixOS modules, packages, overlays) takes what it needs as explicit arguments or module options, so it stays usable outside the flake that defines it.

This restriction is relaxed for flake modules (`flake-parts` modules and anything else evaluated as part of the flake outputs), where `inputs` and `self` are part of the module arguments by design.

Any deviation needs a justification stated in the code or the PR.
