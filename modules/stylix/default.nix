{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.dotfiles.stylix.enable = lib.mkEnableOption "Stylix theming (scoped to terminals only: kitty, ghostty)";

  config = lib.mkIf config.dotfiles.stylix.enable {
    stylix.enable = true;
    stylix.autoEnable = false; # opt in per-target explicitly below

    # Placeholder scheme (Catppuccin Mocha - has native pink/mauve accents
    # that roughly complement modules/desktops/gnome's pink accent-color).
    # Swap freely.
    stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";

    # Deliberately NOT touching gtk/gnome: modules/desktops/gnome already has
    # substantial deliberate hardcoded dconf theming (pink accent-color,
    # prefer-dark, Papirus icons, breeze_cursors) that a generic stylix
    # base16/gtk target would clash with or duplicate. Revisit once a base16
    # scheme is chosen to match that aesthetic.
    stylix.targets.kitty.enable = true;
    stylix.targets.ghostty.enable = true;
  };
}
