{ pkgs, lib, ... }:
{
  programs.gpg.enable = true;
  services.gpg-agent = {
    enable = true;
    enableSshSupport = true;
    enableZshIntegration = true;
    pinentry = lib.mkIf pkgs.stdenv.isLinux {
      package = pkgs.pinentry-all;
      program = "pinentry-gnome3";
    };
  };
}
