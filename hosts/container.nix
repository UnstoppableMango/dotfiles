{ pkgs, ... }:
{
  # Behind `packages.container`. Leaves off GUI, 1Password, sops, gnupg, and
  # containers, none of which work inside an image.
  home = {
    username = "generic";
    homeDirectory = "/home/generic";
    stateVersion = "25.05";
  };

  dotfiles = {
    git.enable = true;
    ssh.enable = true;
    # The image runs no systemd user manager to host an agent.
    ssh.agent = null;
    zsh.enable = true;
    zsh.ohMyZsh.enable = true;

    c.enable = true;
    go.enable = true;
    python.enable = true;

    ai = {
      enable = true;

      copilot.enable = false;
      cursor.cli.enable = false;
      coderabbit.enable = false;
      omnigent.enable = false;
      opencode.enable = false;

      # Default on; they need a display or toolchains the image lacks.
      azure.enable = false;
      chromeDevtools.enable = false;
      csharp.enable = false;
      fsharp.enable = false;
      haskell.enable = false;
      ocaml.enable = false;
      playwright.enable = false;

      # Size only: gossamer alone pulls in LLVM 18.
      gitMcp.enable = false;
      gossamer.enable = false;
      nix.enable = false;
      rust.enable = false;
      typescript.enable = false;
    };
  };

  programs = {
    tdl.enable = true;

    fzf.enable = true;
    grep.enable = true;
    htop.enable = true;
    jq.enable = true;
    less.enable = true;
    ripgrep.enable = true;
  };

  i18n.glibcLocales = pkgs.glibcLocales.override {
    allLocales = false;
    locales = [ "en_US.UTF-8/UTF-8" ];
  };
}
