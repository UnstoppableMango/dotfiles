{ pkgs, ... }:
{
  # Not all of `home/`: its sops secrets are encrypted to laptop keys only.
  imports = [ ../home/account.nix ];

  home.username = "erik";

  home.packages = with pkgs; [
    nano
    fastfetch
  ];

  dotfiles = {
    git.enable = true;
    gnupg.enable = true;
    gnupg.pinentry = pkgs.pinentry-curses;
    nix.enable = true;
    sops.enable = true;
    ssh.enable = true;
    zsh.enable = true;
    zsh.ohMyZsh.enable = true;

    containers.enable = true;
    kubernetes.enable = true;
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
