# https://nix-community.github.io/home-manager/options.xhtml#opt-programs.vscode.enable
{ pkgs, ... }:
{
  enable = true;
  haskell = {
    enable = true;

    # TODO: https://nix-community.github.io/home-manager/options.xhtml#opt-programs.vscode.haskell.hie.executablePath
    hie.enable = false;
  };

  profiles.default = {
    enableExtensionUpdateCheck = false;
    enableUpdateCheck = false;
  };

  profiles.Hades = pkgs.callPackage ./profiles/hades.nix {};
}
