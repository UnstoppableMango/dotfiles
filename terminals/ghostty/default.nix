{ lib, config, ... }:
{
  options.dotfiles.ghostty.enable = lib.mkEnableOption "ghostty";

  config = lib.mkIf config.dotfiles.ghostty.enable {
    programs.ghostty = {
      enable = true;
      settings = {
        font-family = "MesloLGS NF";
      };
    };
  };
}
