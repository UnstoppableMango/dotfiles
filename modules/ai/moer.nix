{
  lib,
  config,
  ...
}:
let
  cfg = config.dotfiles.ai;
in
{
  options.dotfiles.ai.moer = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        moer: Mixture-of-Experts code review with mandatory verification.
        Dispatches 7 specialist reviewers (correctness, security,
        concurrency, test quality, resilience, performance, policy), 2
        passes each, then requires the agent to verify every claim against
        the actual diff before presenting to the human. Claude Code only:
        built on the task()/background subagent dispatch mechanism, which
        Copilot CLI has no equivalent of.
      '';
    };
  };

  config = lib.mkIf (cfg.enable && cfg.moer.enable) {
    programs.claude-code = {
      skills.moer = ./moer/SKILL.md;
      agentsDir = ./moer/agents;
    };
  };
}
