{ lib, overlay, ... }:
{
  imports = [ ./vscode/tractor-zoom.nix ];

  options.dotfiles.tractorZoom = lib.mkEnableOption "Tractor Zoom work machine profile";

  config = {
    nixpkgs.overlays = [ overlay ];
    nixpkgs.config.allowUnfree = true;

    dotfiles.enable = true;
    dotfiles.tractorZoom = true;
  };
}
