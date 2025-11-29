{
  imports = [
    ./dconf/home.nix
  ];

  home.packages = with pkgs; [
    # For gsconnect
    nautilus-python
  ]
  ++ (with pkgs.gnomeExtensions; [
    appindicator
    dash-to-dock
    docker
    tweaks-in-system-menu
    user-themes
    gsconnect
  ]);
}
