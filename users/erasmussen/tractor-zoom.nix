{
  imports = [ ./vscode/tractor-zoom.nix ];

  nixpkgs.config.allowUnfree = true;
  dotfiles.enable = true;
}
