# Shell, editors, and apps

## zsh/

zsh, Powerlevel10k, and a framework: oh-my-zsh (`dotfiles.zsh.ohMyZsh.enable`) or prezto (`dotfiles.zsh.prezto.enable`), mutually exclusive by assertion.
`dotfiles.zsh.enable` is the base shell (aliases, history, completion) plus the prompt.
The bundled `.p10k.zsh` sits beside it, and `dotfiles.zsh.p10kConfig` points at it; a consumer can replace it or set null.
`oh-my-zsh/` and `prezto/` are submodules, each active only alongside `dotfiles.zsh.enable`.
The prezto config is kept, switched off on every host.

## Editors

`vscode/`, `vscodium/`, `neovim/` (via nixvim), `zed/`, `helix/`, `emacs/`, and `obsidian/`.

- `vscodium/` mirrors `vscode/` over Home Manager's separate `programs.vscodium` (its own `~/.vscode-oss` and `~/.config/VSCodium`), so a host can enable both.
  Only `hosts/generic.nix` enables it.
- `neovim/nixvim-config.nix` is the curated LSP and plugin set, imported when `dotfiles.neovim.defaultConfig` is on.
- `zed/` carries the extension list as the `dotfiles.zed.extensions` default.

## home-manager/

The `homeup` command: a `home-manager switch` from a local checkout that works from any directory, on hosts that set `dotfiles.homeManager.enable`.

- `dotfiles.homeManager.flakePath` (`~/src/github.com/UnstoppableMango/dotfiles` by default) is baked into the script, so it needs no cwd or environment.
- It lets home-manager resolve `$USER@$HOSTNAME` unless `configuration` names one, passes `-b hm-backup` (`backupExtension`), and passes any unrecognized argument through.
- `homeup -u` runs `nix flake update` first, which rewrites `flake.lock` in the checkout.

`flake-update/` automates flake updates and switches the same checkout (`dotfiles.automation.flakeUpdate.flakePath` defaults to `dotfiles.homeManager.flakePath`).

## Apps

- `bizhawk/`: BizHawk, launched as `emuhawk`, from `mangopkgs`, since nixpkgs has no package and upstream's Nix expression is no flake.
  Upstream publishes an x86_64-linux build only.
- `brave/`: Brave.
- `signal/`: the desktop app (`dotfiles.signal.desktop`) and `signal-cli` (`dotfiles.signal.cli`), each on by default under `dotfiles.signal.enable`.
  A headless host that wants the CLI alone sets `dotfiles.signal.desktop = false`.

## slip/

slip (https://github.com/unmango/slip) is a zettelkasten capture tool that hands any command it does not implement to zk.
slip has no config file, so the surface is one directory.

- `dotfiles.slip.notebook.path` (`notes`, relative to home) is exported as `ZK_NOTEBOOK_DIR` rather than slip's `ZK_DIR`, because zk honours that variable too and both halves of the passthrough have to aim at the same corpus.
- The path is relative because `dotfiles.slip.notebook.init` declares it as a `nix2git.repositories` entry, and nix2git resolves paths against home.
  nix2git runs `git init` for a missing path and never clones, rewrites, or deletes, so it is safe alongside a corpus cloned by hand.
- `dotfiles.slip.zk.settings` renders zk's global `~/.config/zk/config.toml`, which a notebook's `.zk/config.toml` inherits from.
  Its default is the stanza `slip init` would append (`creation-date-key = "create_time"`), which makes zk read a note's creation time from slip's frontmatter rather than the file's mtime.
  Declaring it globally covers every notebook and keeps the setting out of a notes repository's history.
