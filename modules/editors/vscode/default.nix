{
  pkgs,
  lib,
  config,
  ...
}:
{
  imports = [ ./profiles/hades ];

  options.dotfiles.vscode.enable = lib.mkEnableOption "VSCode";

  config = lib.mkIf config.dotfiles.vscode.enable {
    # https://nix-community.github.io/home-manager/options.xhtml#opt-programs.vscode.enable
    programs.vscode = {
      enable = true;
      haskell = {
        enable = true;

        # TODO: https://nix-community.github.io/home-manager/options.xhtml#opt-programs.vscode.haskell.hie.executablePath
        hie.enable = false;
      };

      profiles.default = {
        enableExtensionUpdateCheck = false;
        enableUpdateCheck = false;

        # Not on the marketplace, from the gossamer package's editorSupport
        # passthru instead.
        extensions = [ pkgs.gossamer.passthru.editorSupport.vscode ];

        # TODO: This doesn't count as the "default" profile for app-level settings
        userSettings = {
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
    };
  };
}
