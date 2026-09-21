{ lib, config, ... }:
{
  config = lib.mkIf config.dotfiles.vscode.enable {
    # TODO: This doesn't count as the "default" profile for app-level settings
    programs.vscode.profiles.default.userSettings = {
      "docker.extension.enableComposeLanguageServer" = true;
      "resharper.dataSharing.allowDataSharing" = false;
      "telemetry.telemetryLevel" = "off";
      "window.nativeTabs" = true;
      "terminal.integrated.fontFamily" = "MesloLGS NF";

      # TODO: The xterm.js webgl renderer corrupts long Claude Code sessions.
      # Revert when VS Code ships https://github.com/xtermjs/xterm.js/pull/5883.
      "terminal.integrated.gpuAcceleration" = "off";
    };
  };
}
