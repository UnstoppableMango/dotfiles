{
  lib,
  config,
  ...
}:
let
  cfg = config.dotfiles.ai;

  agents = {
    tdd-red = ./tdd-orchestrator/agents/tdd-red.agent.md;
    tdd-green = ./tdd-orchestrator/agents/tdd-green.agent.md;
    tdd-refactor = ./tdd-orchestrator/agents/tdd-refactor.agent.md;
  };
in
{
  options.dotfiles.ai.tddOrchestrator = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        tdd-orchestrator (Source Allies): strict red/green/refactor TDD
        loop driven by three isolated subagents (tdd-red, tdd-green,
        tdd-refactor), each in its own context window. Reads the target
        repo's AGENTS.md for language/test-framework/path conventions.
        Works with both Claude Code and Copilot CLI via the native
        Task-tool/subagent dispatch and *.agent.md convention each
        already supports.
      '';
    };
  };

  config = lib.mkIf (cfg.enable && cfg.tddOrchestrator.enable) {
    programs.claude-code = {
      skills.tdd-orchestrator = ./tdd-orchestrator/SKILL.md;
      inherit agents;
    };

    programs.github-copilot-cli = {
      skills.tdd-orchestrator = ./tdd-orchestrator/SKILL.md;
      inherit agents;
    };
  };
}
