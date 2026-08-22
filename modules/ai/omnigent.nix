{
  lib,
  config,
  ...
}:
let
  cfg = config.dotfiles.ai.omnigent;
in
{
  options.dotfiles.ai.omnigent = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
    programs.uv.tool.packages = [ "omnigent" ];

    home.sessionPath = [ "$HOME/.local/bin" ];
  };
}
