{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.dotfiles.ai;

  # https://github.com/mattpocock/skills
  mattpocockSrc = pkgs.fetchFromGitHub {
    owner = "mattpocock";
    repo = "skills";
    rev = "49dd158d1076134a641b33efb035946536778336";
    sha256 = "sha256-NljCSZNI3sZ+vbCw7pRdrwR7try4BxOFp4gdjuWYtzs=";
  };

  # The `skills` array of .claude-plugin/plugin.json, the promoted set.
  skillPaths = [
    "engineering/ask-matt"
    "engineering/diagnosing-bugs"
    "engineering/grill-with-docs"
    "engineering/triage"
    "engineering/improve-codebase-architecture"
    "engineering/setup-matt-pocock-skills"
    "engineering/tdd"
    "engineering/to-spec"
    "engineering/to-tickets"
    "engineering/wayfinder"
    "engineering/implement"
    "engineering/implement-spec"
    "engineering/prototype"
    "engineering/research"
    "engineering/domain-modeling"
    "engineering/codebase-design"
    "engineering/code-review"
    "engineering/pr"
    "engineering/retro"
    "engineering/wizard"
    "productivity/grill-me"
    "productivity/grilling"
    "productivity/handoff"
    "productivity/teach"
    "productivity/to-questionnaire"
    "productivity/wait-what"
    "productivity/writing-for-agents"
  ];
in
{
  options.dotfiles.ai.mattpocock = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Matt Pocock's engineering skills (grilling, spec and ticket flows, TDD, code review, domain modeling): the mattpocock-skills plugin for Claude Code, and the same skills mirrored for Copilot CLI.";
    };
  };

  config = lib.mkIf (cfg.enable && cfg.mattpocock.enable) {
    programs.claude-code.plugins.mattpocock-skills = mattpocockSrc;

    programs.github-copilot-cli.skills = lib.listToAttrs (
      map (path: lib.nameValuePair (baseNameOf path) "${mattpocockSrc}/skills/${path}") skillPaths
    );
  };
}
