{ pkgs, ... }:
{
  # Headless: the shell and secret floor, plus the two toolchains a box that
  # runs containers needs. The account comes from `home/account.nix` directly rather
  # than from all of `home/`, because the rest of the personal layer carries
  # sops secrets encrypted to erik's laptop keys that a server has no reason to
  # hold. `account.nix` carries no identity of its own, so the username is set
  # here rather than inherited from `home/default.nix`'s default.
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
