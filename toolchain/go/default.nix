{ lib, config, ... }:
{
  options.dotfiles.go.enable = lib.mkEnableOption "Go Toolchain";

  config = lib.mkIf config.dotfiles.go.enable {
    programs.go = {
      enable = true;
      telemetry.mode = "off";
    };
  };
}
