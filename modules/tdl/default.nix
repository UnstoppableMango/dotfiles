{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.dotfiles.tdl.enable = lib.mkEnableOption "tdl, the type description language compiler";

  config = lib.mkIf config.dotfiles.tdl.enable {
    home.packages = [ pkgs.tdl ];
  };
}
