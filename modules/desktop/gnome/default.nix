{
  pkgs,
  lib,
  config,
  ...
}:
let
  extensions = with pkgs.gnomeExtensions; [
    appindicator
    dash-to-dock
    docker
    gsconnect
    system-monitor
    tweaks-in-system-menu
    user-themes
  ];
in
{
  options.dotfiles.gnome.enable = lib.mkEnableOption "Gnome";

  config = lib.mkIf config.dotfiles.gnome.enable {
    home.packages = [ pkgs.nautilus-python ] ++ extensions;

    # An extension is inert until GNOME is told to load it, so the enabled list
    # is derived from the installed set rather than written out again. Which
    # extensions to install is the choice; keeping the two in step is mechanics.
    dconf = {
      enable = true;
      settings."org/gnome/shell" = {
        disable-user-extensions = false;
        enabled-extensions = map (e: e.extensionUuid) extensions;
      };
    };
  };
}
