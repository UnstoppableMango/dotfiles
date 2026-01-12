{ config, ... }:
{
  imports = [ ./gnome ];

  flake.modules.homeManager.desktops = {
    imports = [ config.flake.modules.homeManager.gnome ];
  };
}
