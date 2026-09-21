{ lib, config, ... }:
{
  options.dotfiles.python.enable = lib.mkEnableOption "Python Toolchain";

  config = lib.mkIf config.dotfiles.python.enable {
    programs.uv.enable = true;

    # Where `uv tool install`, pipx, and `pip --user` put executables.
    home.sessionPath = [ "$HOME/.local/bin" ];
  };
}
