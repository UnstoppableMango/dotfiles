{
  lib,
  config,
  ...
}:
let
  cfg = config.dotfiles.ai;
in
{
  options.dotfiles.ai.commentCleanup = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        comment-cleanup: a comment-only editing pass that deletes narration,
        change notes and pointers to moving targets, trims bloated rationale,
        and keeps comments that carry a real why, then reports counts and
        flags. From https://gist.github.com/bavanws/123e0343f8a79cec825d9141124a0a83.
        Plain markdown, so it installs for both Claude Code and Copilot CLI.
      '';
    };
  };

  config = lib.mkIf (cfg.enable && cfg.commentCleanup.enable) {
    programs.claude-code.skills.comment-cleanup = ./comment-cleanup/SKILL.md;
    programs.github-copilot-cli.skills.comment-cleanup = ./comment-cleanup/SKILL.md;
  };
}
