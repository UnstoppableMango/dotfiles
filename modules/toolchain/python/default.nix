{ lib, config, ... }:
{
  options.dotfiles.python.enable = lib.mkEnableOption "Python Toolchain";

  config = lib.mkIf config.dotfiles.python.enable {
    programs.uv.enable = true;

    # `uv tool install` (and pipx, pip --user) place executables here, so keep
    # it on PATH whenever uv is available.
    home.sessionPath = [ "$HOME/.local/bin" ];
  };
}
