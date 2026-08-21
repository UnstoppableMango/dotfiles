{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.dotfiles.ai;

  # https://github.com/ayghri/i-have-adhd
  iHaveAdhdSrc = pkgs.fetchFromGitHub {
    owner = "ayghri";
    repo = "i-have-adhd";
    rev = "b42a45a068e080294924bfba19a7a2e8944c48ff";
    sha256 = "sha256-isZtYWU+o32+JpslZlPH/T8HV+b4lHESJHCEWvm0kA8=";
  };
in
{
  options.dotfiles.ai.adhd = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "i-have-adhd: shapes output to be action-first, numbered, and tangent-free. Permanently enabled via the always-on flag file the plugin's SessionStart hook checks for, rather than left opt-in per-session via /i-have-adhd. Copilot CLI gets just the skill mirrored, since it has no plugin/hook system to run that hook.";
    };
  };

  config = lib.mkIf (cfg.enable && cfg.adhd.enable) {
    programs.claude-code.plugins."i-have-adhd" = iHaveAdhdSrc;

    programs.github-copilot-cli.skills."i-have-adhd" = "${iHaveAdhdSrc}/skills/i-have-adhd";

    # Presence alone enables always-on mode; hooks/always-on.mjs only checks
    # fs.existsSync on this path, content is irrelevant.
    home.file."${lib.removePrefix "${config.home.homeDirectory}/" config.programs.claude-code.configDir}/.i-have-adhd-always".text =
      "";

    home.packages = [ pkgs.nodejs ];
  };
}
