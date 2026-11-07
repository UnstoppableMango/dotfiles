{ lib, pkgs, ... }:
{
  # tz's account on hades, for work. The system account comes from the `tz`
  # users instance in the nixos repo, which also installs the Home Manager
  # CLI, the 1Password app and Tailscale. Nothing here names an employer or a
  # person: github.com/erasmussen-tz/dotfiles extends this configuration with
  # the identity (git name, email and signing key, AWS profiles, the
  # 1Password reference for the OpenRouter key).
  home = {
    username = "tz";
    homeDirectory = "/home/tz";
    stateVersion = "26.05";
  };

  dotfiles = {
    fonts.enable = true;
    git.enable = true;
    kitty.enable = true;
    ssh.enable = true;
    zsh.enable = true;
    zsh.ohMyZsh.enable = true;

    # The app and its setgid `op` come from the system; this adds the SSH
    # agent and commit signing through it. Work secrets live in 1Password,
    # so tz has no sops.
    onePassword.enable = true;
    ssh.agent = "1password";

    javascript.enable = true;
    javascript.corepack.enable = true;
    python.enable = true;
    vscode.enable = true;

    ai = {
      enable = true;

      # gh holds the token, from `gh auth login`.
      github.ghAuth = true;
      slack.enable = true;

      copilot.enable = false;
      cursor.cli.enable = false;
      coderabbit.enable = false;
      omnigent.enable = false;
      opencode.enable = false;

      # Toolchains work does not use.
      azure.enable = false;
      csharp.enable = false;
      fsharp.enable = false;
      go.enable = false;
      gossamer.enable = false;
      haskell.enable = false;
      kubernetes.enable = false;
      ocaml.enable = false;
      rust.enable = false;
      terraform.enable = false;
      containers.enable = false;

      # Personal accounts that sign in through a browser.
      cloudflare.enable = false;
      gitlab.enable = false;
      pulumi.enable = false;
    };
  };

  programs = {
    home-manager.enable = true;

    # Profiles are identity, so erasmussen-tz/dotfiles sets `settings`.
    awscli.enable = true;
    gh.enable = true;

    # No neovim here; the git module's default editor is nvim.
    git.settings.core.editor = lib.mkForce "code --wait";

    vscode.profiles.default.extensions = with pkgs.vscode-extensions; [
      dbaeumer.vscode-eslint
      esbenp.prettier-vscode
      ms-python.debugpy
      ms-python.python
      ms-python.vscode-pylance
    ];

    fzf.enable = true;
    jq.enable = true;
    ripgrep.enable = true;
  };

  home.packages = with pkgs; [
    google-chrome
    slack
    zoom-us
  ];
}
