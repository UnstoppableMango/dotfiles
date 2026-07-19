{ lib, config, ... }:
{
  options.dotfiles.python.enable = lib.mkEnableOption "Python Toolchain";

  config = lib.mkIf config.dotfiles.python.enable {
    programs.uv.enable = true;
  };
}
