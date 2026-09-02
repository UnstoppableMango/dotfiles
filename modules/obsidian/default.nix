{ lib, config, ... }:
{
  options.dotfiles.obsidian.enable = lib.mkEnableOption "Obsidian";

  config = lib.mkIf config.dotfiles.obsidian.enable {
    programs.obsidian.enable = true;
  };
}
