{ config, ... }:
{
  imports = [
    ./erasmussen
    ./erik
  ];

  flake.modules.homeManager.users = {
    imports = with config.flake.modules.homeManager; [
      erik
      erasmussen
    ];
  };
}
