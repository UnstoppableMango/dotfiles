{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.dotfiles.ai;

  # https://github.com/github/gh-stack
  ghStackSrc = pkgs.fetchFromGitHub {
    owner = "github";
    repo = "gh-stack";
    rev = "ab00aa4a3f2dddc51aa65849c68b391a1b079311";
    sha256 = "sha256-hyZbC4jEC7A7GJ9dn8coYeoC5MCk0Eei/W8EwsrSMo4=";
  };
  ghStackSkill = "${ghStackSrc}/skills/gh-stack";
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
    programs.claude-code.skills.gh-stack = ghStackSkill;
    programs.github-copilot-cli.skills.gh-stack = ghStackSkill;

    programs.gh = {
      enable = true;
      extensions = [ pkgs.gh-stack ];
    };
  };
}
