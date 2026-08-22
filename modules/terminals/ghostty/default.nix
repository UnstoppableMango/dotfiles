{ lib, config, ... }:
{
  options.dotfiles.ghostty.enable = lib.mkEnableOption "ghostty";

  config = lib.mkIf config.dotfiles.ghostty.enable {
    programs.ghostty = {
      enable = true;
      settings = {
        # mkForce: stylix's ghostty target (see modules/stylix) also sets
        # font-family at normal priority, which conflicts outright.
        font-family = lib.mkForce config.dotfiles.zsh.font;
      };
    };
  };
}
