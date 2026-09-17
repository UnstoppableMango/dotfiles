{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.dotfiles.signal;
in
{
  options.dotfiles.signal = {
    enable = lib.mkEnableOption "Signal";

    desktop = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Install the Signal desktop app, which needs a display.";
    };

    cli = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Install signal-cli.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages =
      lib.optional cfg.desktop pkgs.signal-desktop ++ lib.optional cfg.cli pkgs.signal-cli;
  };
}
