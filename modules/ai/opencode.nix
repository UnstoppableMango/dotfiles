{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.dotfiles.ai.opencode;
in
{
  options.dotfiles.ai.opencode = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
    programs.opencode = {
      enable = true;
    };

    home.packages = with pkgs; [
      opencode-desktop
      opencode-claude-auth
    ];
  };
}
