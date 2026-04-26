{ lib, config, ... }:
{
  options.dotfiles.helix.enable = lib.mkEnableOption "helix";

  config = lib.mkIf config.dotfiles.helix.enable {
    programs.helix.enable = true;
  };
}
