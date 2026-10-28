{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.dotfiles.fonts.enable = lib.mkEnableOption "Nerd Fonts (MesloLGS NF, FiraCode Nerd Font Mono) referenced by name in zsh/kitty/ghostty/gnome but never previously installed, plus Noto Color Emoji";

  config = lib.mkIf config.dotfiles.fonts.enable {
    fonts.fontconfig.enable = true;

    # An emoji font from the profile rather than relying on the distro's: an
    # app in a buildFHSEnv sandbox (claude-desktop-fhs) gets the host's
    # /etc/fonts but the sandbox's own /usr, so the distro's /usr/share/fonts
    # vanishes and only the fonts Home Manager points fontconfig at remain.
    fonts.fontconfig.defaultFonts.emoji = lib.mkDefault [ "Noto Color Emoji" ];

    home.packages = with pkgs; [
      nerd-fonts.meslo-lg
      nerd-fonts.fira-code
      noto-fonts-color-emoji
    ];
  };
}
