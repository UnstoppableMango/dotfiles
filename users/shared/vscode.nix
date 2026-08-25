{ lib, config, ... }:
{
  config = lib.mkIf config.dotfiles.vscode.enable {
    # TODO: This doesn't count as the "default" profile for app-level settings
    programs.vscode.profiles.default.userSettings = {
      "docker.extension.enableComposeLanguageServer" = true;
      "telemetry.telemetryLevel" = "off";
      "window.nativeTabs" = true;
      "terminal.integrated.fontFamily" = "MesloLGS NF";

      # TODO: Revert once upstream fixed. GPU renderer corrupts long
      # Claude Code sessions (black/solid block glyphs). Root cause is an
      # upstream xterm.js webgl-renderer bug; the actual fix is
      # https://github.com/xtermjs/xterm.js/pull/5883 (merged 2026-05-21
      # but not yet in a published xterm.js release, so VS Code hasn't
      # picked it up). Tracking:
      # https://github.com/anthropics/claude-code/issues/8097
      # https://github.com/anthropics/claude-code/issues/59163
      # https://github.com/anthropics/claude-code/issues/59539
      # https://github.com/anthropics/claude-code/issues/8618
      "terminal.integrated.gpuAcceleration" = "off";
    };
  };
}
