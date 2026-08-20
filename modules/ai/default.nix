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
  imports = [ ./opencode.nix ];

  options.dotfiles.ai = {
    enable = lib.mkEnableOption "slop";
  };

  config = lib.mkIf cfg.enable {
    programs.claude-code.enable = true;

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
