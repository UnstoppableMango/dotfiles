{ lib, pkgs, ... }:
{
  # The headless, identity-free configuration behind `packages.container`.
  # Same shape as `generic.nix` minus anything that needs a session or a
  # machine: no GUI, no 1Password (its agent socket belongs to the desktop
  # app), no sops (an image holds no age key), no gpg-agent (pinentry needs
  # a session), and no containers (rootless podman does not run inside one).
  home = {
    username = "generic";
    homeDirectory = "/home/generic";
    stateVersion = "25.05";

    # The base userland scripts and agents expect, which the image's base
    # layer leaves out. hiPrio settles the utilities uutils shares with
    # procps and others in its favour.
    packages = with pkgs; [
      (lib.hiPrio uutils-coreutils-noprefix)
      curl
      diffutils
      file
      findutils
      gawk
      gnumake
      gnused
      gnutar
      gzip
      openssh
      patch
      procps
      rsync
      unzip
      which
      xz
      zip
      zstd
    ];

    sessionVariables = {
      GH_PAGER = "cat";
      MANPAGER = "cat";
      PAGER = "cat";
    };
  };

  dotfiles = {
    git.enable = true;
    ssh.enable = true;
    # The image runs no systemd user manager to host an agent.
    ssh.agent = null;
    zsh.enable = true;
    # No terminal ever renders a prompt here.
    zsh.p10kConfig = null;

    c.enable = true;
    go.enable = true;
    python.enable = true;

    ai = {
      enable = true;

      # gh holds the GitHub App token the-cluster's sidecar rotates hourly.
      github.ghAuth = true;

      # Claude Code only: every other agent CLI is off.
      copilot.enable = false;
      cursor.cli.enable = false;
      coderabbit.enable = false;
      omnigent.enable = false;
      opencode.enable = false;

      # On by default under ai.enable. Off here because the image has no
      # display for a browser and none of these toolchains, and together they
      # are several GB (ghc, two .NET SDKs, ocaml, azure-cli).
      azure.enable = false;
      chromeDevtools.enable = false;
      csharp.enable = false;
      fsharp.enable = false;
      haskell.enable = false;
      ocaml.enable = false;
      playwright.enable = false;

      # Size, not function: gossamer alone pulls in LLVM 18.
      gitMcp.enable = false;
      gossamer.enable = false;
      nix.enable = false;
      rust.enable = false;
      typescript.enable = false;
    };
  };

  programs = {
    tdl.enable = true;

    grep.enable = true;
    jq.enable = true;
    ripgrep.enable = true;

    # Nothing reads a pager or an editor here: output goes to an agent, not a
    # terminal. `cat` keeps paging commands printing, and `true` lets a merge
    # or rebase keep its default message instead of waiting on nvim.
    git.settings.core = {
      editor = lib.mkForce "true";
      pager = "cat";
    };
    gh.settings.pager = "cat";
    # Its git integration sets pagers that pipe into less.
    diff-highlight.enable = lib.mkForce false;
  };

  i18n.glibcLocales = pkgs.glibcLocales.override {
    allLocales = false;
    locales = [ "en_US.UTF-8/UTF-8" ];
  };
}
