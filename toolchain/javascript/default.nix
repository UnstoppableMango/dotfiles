{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.dotfiles.javascript.enable = lib.mkEnableOption "JavaScript Toolchain";

  config = lib.mkIf config.dotfiles.javascript.enable {
    home.packages = with pkgs; [
      fnm
    ];

    programs.zsh.initContent = ''
      eval "$(${pkgs.fnm}/bin/fnm env --use-on-cd --shell zsh)"
    '';
  };
}
