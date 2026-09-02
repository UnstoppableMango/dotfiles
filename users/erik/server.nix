{ pkgs, lib, ... }:
let
  username = "erik";
in
{
  imports = [
    ../../modules/gnupg
    ../../modules/shells
    ../../modules/sops
    ../../modules/ssh
    ../../modules/toolchain
  ];

  home = {
    inherit username;
    homeDirectory = "/home/${username}";
    sessionVariables.DO_NOT_TRACK = "1";
    packages = with pkgs; [
      nano
      fastfetch
    ];
  };

  dotfiles = {
    zsh.enable = true;
    containers.enable = true;
    git.enable = true;
    gnupg.enable = true;
    kubernetes.enable = true;
    nix.enable = true;
    sops.enable = true;
    ssh.enable = true;
  };

  # gnupg module hardcodes pinentry-gnome3, which needs a GNOME/D-Bus session
  services.gpg-agent.pinentry = {
    package = lib.mkForce pkgs.pinentry-curses;
    program = lib.mkForce "pinentry-curses";
  };

  programs = {
    home-manager.enable = true;
    grep.enable = true;
    htop.enable = true;
    fzf.enable = true;
    jq.enable = true;
    less.enable = true;
    ripgrep.enable = true;
    vim.enable = true;
    direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };

  home.stateVersion = "25.05";
}
