{
  lib,
  config,
  ...
}:
{
  options.dotfiles.stylix.enable = lib.mkEnableOption "Stylix theming (scoped to terminals and the i3 session)";

  config = lib.mkIf config.dotfiles.stylix.enable {
    stylix.enable = true;
    stylix.autoEnable = false;

    # base0D, the accent most targets use for focus, is the hot pink.
    stylix.base16Scheme = lib.mkDefault ./hot-pink.yaml;

    # No gtk/gnome targets: they would clash with the dconf theming in home/gnome.nix.
    stylix.targets.kitty.enable = true;
    stylix.targets.ghostty.enable = true;
  };
}
