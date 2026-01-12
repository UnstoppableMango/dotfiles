{ config, ... }:
{
  imports = [ ./zsh ];

  flake.modules.homeManager.shells = {
    imports = with config.flake.modules.homeManager; [
      zsh
    ];
  };
}
