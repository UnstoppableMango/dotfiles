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
      zx
    ];

    programs.zsh.initContent = lib.mkIf config.dotfiles.zsh.enable ''
      eval "$(${pkgs.fnm}/bin/fnm env --use-on-cd --shell zsh)"
    '';
  };
}
