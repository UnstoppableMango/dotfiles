{ config, lib, ... }:
{
  options.dotfiles.brave.enable = lib.mkEnableOption "Brave Browser";
  config.programs.brave.enable = config.dotfiles.brave.enable;
}
