# modules/

Class modules: how a piece of software is configured, with no identity baked in.
Personalization enters only as a `dotfiles.<x>.<y>` option (data), never as a literal value.

## Rules

- One directory per piece of software, each with a `default.nix`, and no category layer.
  `modules/default.nix` imports every subdirectory that has a `default.nix`, read from disk, so adding a module is creating the directory.
- Every `dotfiles.*` module is off by default and every `config` block is `mkIf`-gated, so importing `homeModules.dotfiles` turns nothing on.
  A sub-toggle may default on under its parent's `enable` (`dotfiles.signal.desktop`, `dotfiles.openrouter.<tool>.enable`).
- Put a curated value any consumer would plausibly want here as an option default, or as `mkDefault` on the tool's settings: the nixvim LSP and plugin set (`dotfiles.neovim.defaultConfig`), the p10k config (`dotfiles.zsh.p10kConfig`), the Zed extension list (`dotfiles.zed.extensions`), kitty's font and colors, the k9s skin, Zed's Copilot and telemetry settings, and the checkout-root doc (`dotfiles.ai.checkoutRoot.context`).
  A consumer overrides with a plain assignment; there is no separate taste toggle.
- Never set `nixpkgs.overlays`, `nixpkgs.config`, or `nix.package`; `hosts/common.nix` owns them (see [architecture](../docs/agents/architecture.md#nixpkgs-ownership)).
  A module that writes `nix.settings` leaves `nix.package` alone.
- Never branch on the host inside a module; a value that differs between machines goes in `hosts/<machine>.nix`.
- When a module accretes config for one sub-tool (more than one or two files), split it into a submodule directory with its own `default.nix`, aggregated by the parent (`kubernetes/{k9s,openshift,rosequartz}`, `zsh/{oh-my-zsh,prezto}`).
- A module that runs a local stdio MCP server splits `enable` (packages, LSP servers, skills) from `mcp.enable` (the server registration, default `false`), because every configured server starts with each Claude Code and Copilot CLI session.
  A project that wants one of those servers declares it in a repo-local `.mcp.json`.
  An HTTP server starts no local process and registers under `enable` alone.
- Take data from flake inputs as an option that `hosts/common.nix` sets (`dotfiles.ssh.hosts`, `dotfiles.ai.mattpocock.src`), rather than closing over `inputs`.
- Software with no nixpkgs package and no upstream flake comes from the `mangopkgs` overlay (https://github.com/unmango/pkgs), taken as a `package` option default.
  There is no `pkgs/` directory here.

## Drift signals

- A literal (an email, a color hex, a hostname, an API key path) hardcoded inside `modules/`.
- A `dotfiles.*` option declared outside `modules/`.
- A per-host branch inside a module.

## Module notes

Per-module mechanics and the reasons behind them:

- [ai and openrouter](../docs/agents/modules/ai.md)
- [git](../docs/agents/modules/git.md)
- [ssh, gnupg, onepassword, sops, yubikey, github token](../docs/agents/modules/security.md)
- [gnome, i3, hyprland, stylix, fonts, terminals, launch-services](../docs/agents/modules/desktop.md)
- [containers, kubernetes, languages](../docs/agents/modules/toolchains.md)
- [zsh, editors, home-manager, and apps](../docs/agents/modules/apps.md)
