{ pkgs, ... }:
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
  };

  dotfiles = {
    git.enable = true;
    ssh.enable = true;
    zsh.enable = true;

    c.enable = true;
    go.enable = true;
    python.enable = true;

    ai = {
      enable = true;

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
