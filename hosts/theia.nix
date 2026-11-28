{ pkgs, ... }:
{
  # theia is a rosequartz worker with a GNOME session on its 5K display, not a
  # second hades. Like server.nix it skips the rest of `home/`, whose sops
  # secrets are encrypted to keys theia does not hold.
  imports = [ ../home/account.nix ];

  home.username = "erik";

  home.packages = with pkgs; [
    fastfetch
    vlc
  ];

  dotfiles = {
    git.enable = true;
    gnupg.enable = true;
    nix.enable = true;
    sops.enable = true;
    ssh.enable = true;
    zsh.enable = true;
    zsh.ohMyZsh.enable = true;

    containers.enable = true;
    kubernetes.enable = true;

    brave.enable = true;
    fonts.enable = true;
    ghostty.enable = true;
    gnome.enable = true;
    stylix.enable = true;
  };

  programs = {
    home-manager.enable = true;

    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };

    fzf.enable = true;
    grep.enable = true;
    htop.enable = true;
    jq.enable = true;
    less.enable = true;
    ripgrep.enable = true;
    vim.enable = true;
  };
}
