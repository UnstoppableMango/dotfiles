{ pkgs, ... }:
let
  inherit (pkgs.stdenv.hostPlatform) isDarwin isLinux;
in
{
  # A home configuration with no identity in it: most of the modules on, plus
  # the account fields Home Manager requires. Nothing from `home/`.
  #
  # No machine is named `generic` and no person is either. It exists so
  # `homeModules.dotfiles` is built here rather than only breaking in whatever
  # flake consumes it, which is the same reason `erik@server` exists. The
  # darwin build is also the only consumer of the darwin branches in
  # `modules/`.
  home = {
    username = "generic";
    homeDirectory = if isDarwin then "/Users/generic" else "/home/generic";
    stateVersion = "25.05";
  };

  dotfiles = {
    git.enable = true;
    gnupg.enable = true;
    nix.enable = true;
    onePassword.enable = true;
    sops.enable = true;
    ssh.enable = true;
    zsh.enable = true;

    c.enable = true;
    containers.enable = true;
    go.enable = true;
    javascript.enable = true;
    kubernetes.enable = true;
    neovim.enable = true;
    python.enable = true;

    ai = {
      enable = true;
      claudeDesktop.enable = true;
    };

    fonts.enable = true;
    ghostty.enable = true;
    helix.enable = true;
    kitty.enable = true;
    obsidian.enable = true;
    stylix.enable = true;
    vscode.enable = true;
    zed.enable = true;

    # A Linux desktop session.
    brave.enable = isLinux;
    gnome.enable = isLinux;
  };

  programs = {
    home-manager.enable = true;
    tdl.enable = true;

    fzf.enable = true;
    grep.enable = true;
    htop.enable = true;
    jq.enable = true;
    less.enable = true;
    ripgrep.enable = true;
    vim.enable = true;
  };
}
