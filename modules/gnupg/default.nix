{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.dotfiles.gnupg.enable = lib.mkEnableOption "gnupg";

  config = lib.mkIf config.dotfiles.gnupg.enable {
    programs.gpg.enable = true;
    services.gpg-agent = {
      enable = true;
      enableSshSupport = true;
      enableZshIntegration = true;
      pinentry = lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
        package = pkgs.pinentry-all;
        program = "pinentry-gnome3";
      };
    };
  };
}
