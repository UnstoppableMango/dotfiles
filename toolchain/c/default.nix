{ lib, config, ... }:
{
  options.dotfiles.c.enable = lib.mkEnableOption "c Toolchain";

  config = lib.mkIf config.dotfiles.c.enable {
    programs.gcc.enable = true;
  };
}
