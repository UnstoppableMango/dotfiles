{ lib, config, ... }:
{
  # The extension list lives in modules/zed as the `dotfiles.zed.extensions`
  # default; what is left here is taste rather than tooling.
  config = lib.mkIf config.dotfiles.zed.enable {
    programs.zed-editor.userSettings = {
      features.copilot = true;
      telemetry.metrics = false;
    };
  };
}
