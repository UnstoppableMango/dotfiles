{ config, ... }:
{
  imports = [
    ./ghostty
    ./kitty
  ];

  flake.modules.homeManager.terminals = {
    imports = with config.flake.modules.homeManager; [
      ghostty
      kitty
    ];
  };
}
