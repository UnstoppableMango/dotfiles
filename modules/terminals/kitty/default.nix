{ lib, config, ... }:
{
  options.dotfiles.kitty.enable = lib.mkEnableOption "kitty";

  config = lib.mkIf config.dotfiles.kitty.enable {
    programs.kitty = {
      enable = true;
      enableGitIntegration = true;
      shellIntegration.mode = "no-cursor";
    };
  };
}
