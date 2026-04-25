{
  flake.modules = {
    homeManager.dotfiles =
      { config, lib, ... }:
      {
        options.dotfiles.brave.enable = lib.mkEnableOption "Brave Browser";
        config.programs.brave.enable = config.dotfiles.brave.enable;
      };

    nixos.dotfiles =
      { config, lib, ... }:
      {
        options.dotfiles.brave.enable = lib.mkEnableOption "Brave Browser";
        config.home-manager.dotfiles.brave.enable = config.dotfiles.brave.enable;
      };
  };
}
