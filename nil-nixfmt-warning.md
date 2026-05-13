# nixfmt-rfc-style Evaluation Warning

## Warning

```
evaluation warning: nixfmt-rfc-style is now the same as pkgs.nixfmt which should be used instead.
```

## Source

**nixpkgs** `pkgs/top-level/aliases.nix:1533` — `warnAlias` added 2025-07-14:

```nix
warnAlias "nixfmt-rfc-style is now the same as pkgs.nixfmt which should be used instead." nixfmt
```

Fires whenever `pkgs.nixfmt-rfc-style` is forced during evaluation.

## Root Cause

**`github:oxalica/nil`** — `flake.nix:29,45`:

```nix
mkNil =
  {
    rustPlatform,
    nixVersions,
    nixfmt-rfc-style,  # <-- line 29: passed from pkgs via callPackage
    ...
  }:
  rustPlatform.buildRustPackage {
    ...
    CFG_DEFAULT_FORMATTER = lib.getExe nixfmt-rfc-style;  # <-- line 45
    ...
  };
```

The `nil` package bakes `nixfmt-rfc-style` into the binary as the default formatter path. When `nil.overlays.default` is applied and the `nil` package is evaluated, `callPackage` resolves `nixfmt-rfc-style` from `pkgs`, triggering the alias warning.

**Call chain:**

```
dotfiles flake.nix
  → nil.overlays.default (applied in overlay composition)
  → callPackage mkNil pkgs
  → pkgs.nixfmt-rfc-style forced
  → nixpkgs aliases.nix:1533 warnAlias fires
```

## Not the Cause

- `treefmt.programs.nixfmt.enable = true` in dotfiles — uses `pkgs.nixfmt` directly, no warning
- `clan-core/formatter.nix:12` — does reference `pkgs.nixfmt-rfc-style` but not evaluated from dotfiles (only clan-core's own checks force it)
- `zed/flake.nix:50` — overlay is commented out in dotfiles

## Fix Options

**Option 1: Override in dotfiles overlay (local workaround)**

```nix
# In overlay
nil = prev.nil.override { nixfmt-rfc-style = prev.nixfmt; };
```

**Option 2: Upstream fix in oxalica/nil**

Change `flake.nix` to use `nixfmt` instead of `nixfmt-rfc-style`. Trivial one-line change.

**Option 3: Ignore**

`nixfmt-rfc-style` aliases to `nixfmt` — no functional difference, warning is cosmetic.
