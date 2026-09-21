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
    vscode-recent-folders
  ];
in
{
  options.dotfiles.gnome.enable = lib.mkEnableOption "Gnome";

  config = lib.mkIf config.dotfiles.gnome.enable {
    home.packages = [ pkgs.nautilus-python ] ++ extensions;

    dconf = {
      enable = true;
      settings."org/gnome/shell" = {
        disable-user-extensions = false;
        enabled-extensions = map (e: e.extensionUuid) extensions;
      };
    };
  };
}
