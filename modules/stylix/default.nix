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
    stylix.autoEnable = false;

    # Placeholder, chosen for pink accents near GNOME's accent-color.
    stylix.base16Scheme = "${pkgs.base16-schemes}/share/themes/catppuccin-mocha.yaml";

    # No gtk/gnome targets: they would clash with the dconf theming in home/gnome.nix.
    stylix.targets.kitty.enable = true;
    stylix.targets.ghostty.enable = true;
  };
}
