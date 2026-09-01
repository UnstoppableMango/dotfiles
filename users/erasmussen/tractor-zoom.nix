{
  imports = [
    ./default.nix
    ./vscode/tractor-zoom.nix
  ];

  nixpkgs.config.allowUnfree = true;
}
