{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.dotfiles.gnupg;
in
{
  options.dotfiles.gnupg = {
    enable = lib.mkEnableOption "gpg and gpg-agent, for signing and encryption only (no SSH)";

    pinentry = lib.mkOption {
      type = with lib.types; nullOr package;
      default = if pkgs.stdenv.hostPlatform.isDarwin then pkgs.pinentry_mac else pkgs.pinentry-gnome3;
      defaultText = lib.literalExpression "if isDarwin then pkgs.pinentry_mac else pkgs.pinentry-gnome3";
      example = lib.literalExpression "pkgs.pinentry-curses";
      description = ''
        Passphrase prompt gpg-agent uses. The GNOME one needs a graphical
        session, so a headless machine sets `pkgs.pinentry-curses`.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    programs.gpg.enable = true;
    services.gpg-agent = {
      enable = true;
      enableZshIntegration = true;
      pinentry.package = cfg.pinentry;
    };
  };
}
