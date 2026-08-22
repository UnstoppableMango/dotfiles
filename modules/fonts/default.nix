{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.dotfiles.fonts.enable = lib.mkEnableOption "Nerd Fonts (MesloLGS NF, FiraCode Nerd Font Mono) referenced by name in zsh/kitty/ghostty/gnome but never previously installed";

  config = lib.mkIf config.dotfiles.fonts.enable {
    fonts.fontconfig.enable = true;

    home.packages = with pkgs; [
      nerd-fonts.meslo-lg
      nerd-fonts.fira-code
    ];
  };
}
