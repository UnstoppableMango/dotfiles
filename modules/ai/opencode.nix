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
  imports = [
    (lib.mkRenamedOptionModule
      [ "dotfiles" "ai" "opencode" "openrouter" "enable" ]
      [ "dotfiles" "openrouter" "opencode" "enable" ]
    )
  ];

  options.dotfiles.ai.opencode = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };

    desktop.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "The opencode desktop app (Electron). Headless hosts turn it off.";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.opencode.enable = true;

    home.packages = [
      pkgs.opencode-claude-auth
    ]
    ++ lib.optional cfg.desktop.enable pkgs.opencode-desktop;
  };
}
