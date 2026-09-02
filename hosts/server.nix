{ pkgs, lib, ... }:
{
  # Headless: `base` only, plus the two toolchains a box that runs containers
  # actually needs. The account comes from `home/account.nix` directly rather
  # than from all of `home/`, because the rest of the personal layer carries
  # sops secrets encrypted to erik's laptop keys that a server has no reason to
  # hold.
  imports = [
    ../home/account.nix
    ../profiles/base.nix
  ];

  home.packages = with pkgs; [
    nano
    fastfetch
  ];

  dotfiles = {
    containers.enable = true;
    kubernetes.enable = true;
  };

  # gnupg module hardcodes pinentry-gnome3, which needs a GNOME/D-Bus session
  services.gpg-agent.pinentry = {
    package = lib.mkForce pkgs.pinentry-curses;
    program = lib.mkForce "pinentry-curses";
  };

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
}
