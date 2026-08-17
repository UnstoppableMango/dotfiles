{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.dotfiles.ai = {
    enable = lib.mkEnableOption "Slop";
    agentConfig.enable = lib.mkEnableOption "user-level agent config files (CLAUDE.md, copilot-instructions.md)";
  };

  config = lib.mkMerge [
    (lib.mkIf config.dotfiles.ai.enable {
      programs.claude-code.enable = true;
      home.packages = with pkgs; [
        github-copilot-cli
        cursor-cli
      ];
    })
    (lib.mkIf config.dotfiles.ai.agentConfig.enable {
      home.file = {
        ".claude/CLAUDE.md".source = ./agent-instructions.md;
        ".copilot/copilot-instructions.md".source = ./agent-instructions.md;
      };
      xdg.configFile."caveman/config.json".source =
        (pkgs.formats.json { }).generate "caveman-config.json"
          {
            defaultMode = "off";
          };
    })
  ];
}
