{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.dotfiles.ai;
  json = pkgs.formats.json { };
in
{
  options.dotfiles.ai = {
    enable = lib.mkEnableOption "slop";

    opencode.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
    programs.claude-code.enable = true;

    programs.opencode = {
      enable = cfg.opencode.enable;
    };

    home.packages = with pkgs; [
      github-copilot-cli
      cursor-cli
    ];

    home.file = {
      ".claude/CLAUDE.md".source = ./agent-instructions.md;
      ".copilot/copilot-instructions.md".source = ./agent-instructions.md;
    };

    xdg.configFile."caveman/config.json".source = json.generate "caveman-config.json" {
      defaultMode = "off";
    };
  };
}
