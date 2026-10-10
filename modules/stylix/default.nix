{
  lib,
  config,
  ...
}:
{
  options.dotfiles.stylix.enable = lib.mkEnableOption "Stylix theming (scoped to terminals only: kitty, ghostty)";

  config = lib.mkIf config.dotfiles.stylix.enable {
    stylix.enable = true;
    stylix.autoEnable = false;

    # Placeholder, chosen for pink accents near GNOME's accent-color.
    # Vendored from pkgs.base16-schemes: stylix reads the scheme at eval time,
    # so a store path here would be import from derivation.
    stylix.base16Scheme = ./catppuccin-mocha.yaml;

    # No gtk/gnome targets: they would clash with the dconf theming in home/gnome.nix.
    stylix.targets.kitty.enable = true;
    stylix.targets.ghostty.enable = true;
  };
}
