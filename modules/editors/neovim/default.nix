{
  inputs,
  lib,
  config,
  ...
}:
{
  imports = [ inputs.nixvim.homeModules.nixvim ];

  options.dotfiles.neovim.enable = lib.mkEnableOption "neovim";

  config = lib.mkIf config.dotfiles.neovim.enable {
    programs.nixvim = {
      enable = true;
      defaultEditor = true;

      nixpkgs.useGlobalPackages = true;
    };
  };
}
