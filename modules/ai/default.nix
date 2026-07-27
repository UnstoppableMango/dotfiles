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
        ".claude/CLAUDE.md".source = ./CLAUDE.md;
        ".copilot/copilot-instructions.md".source = ./copilot-instructions.md;
      };
    })
  ];
}
