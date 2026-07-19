{ lib, config, ... }:
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

        # TODO: This doesn't count as the "default" profile for app-level settings
        userSettings = {
          "docker.extension.enableComposeLanguageServer" = true;
          "telemetry.telemetryLevel" = "off";
          "window.nativeTabs" = true;
          "terminal.integrated.fontFamily" = "MesloLGS NF";

          # TODO: Revert once upstream fixed. GPU renderer corrupts long
          # Claude Code sessions (black/solid block glyphs). Tracking:
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
