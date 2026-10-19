{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.dotfiles.bizhawk;
in
{
  options.dotfiles.bizhawk = {
    enable = lib.mkEnableOption "BizHawk, the multi-system emulator, launched as `emuhawk`";

    package = lib.mkPackageOption pkgs "bizhawk" { };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ cfg.package ];
  };
}
