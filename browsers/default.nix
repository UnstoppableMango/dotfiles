{
  imports = [ ./brave ];
  flake.modules.homeManager.browsers =
    { config, ... }:
    {
      imports = [ config.homeManager.brave ];
    };
}
