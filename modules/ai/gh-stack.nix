{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.dotfiles.ai;
  home = config.home.homeDirectory;
  claudeSkills = lib.removePrefix "${home}/" "${config.programs.claude-code.configDir}/skills";
in
{
  options.dotfiles.ai.ghStack = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "gh-stack skill for Claude Code and Copilot CLI: teaches the agent to manage stacked branches and pull requests with the gh-stack GitHub CLI extension.";
    };
  };

  config = lib.mkIf (cfg.enable && cfg.ghStack.enable) {
    skills.install = [ "github/gh-stack@gh-stack" ];

    # Claude Code does not read the skills-nix directory, so it gets a link into it.
    home.file."${claudeSkills}/gh-stack".source = config.lib.file.mkOutOfStoreSymlink "${
      lib.replaceStrings [ "~" ] [ home ] config.skills.dir
    }/gh-stack";

    programs.gh = {
      enable = true;
      extensions = [ pkgs.gh-stack ];
    };
  };
}
