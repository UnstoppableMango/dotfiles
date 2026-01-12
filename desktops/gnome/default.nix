{ config, ... }:
{
  imports = [
    ./dconf
    ./gsconnect
  ];

  flake.modules.homeManager.gnome =
    { pkgs, ... }:
    {
      imports = with config.modules.homeManager; [
        dconf
        gsconnect
      ];

      home.packages = with pkgs.gnomeExtensions; [
        appindicator
        dash-to-dock
        docker
        tweaks-in-system-menu
        user-themes
      ];
    };
}
