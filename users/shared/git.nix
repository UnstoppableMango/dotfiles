{ lib, config, ... }:
{
  config = lib.mkIf config.dotfiles.git.enable {
  };
}
