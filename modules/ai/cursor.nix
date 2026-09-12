{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.dotfiles.ai;
in
{
  options.dotfiles.ai.cursor.editor = {
    enable = lib.mkEnableOption "the Cursor editor";

    package = lib.mkPackageOption pkgs "code-cursor" { };
  };

  config = lib.mkIf (cfg.enable && cfg.cursor.editor.enable) {
    home.packages = [ cfg.cursor.editor.package ];
  };
}
