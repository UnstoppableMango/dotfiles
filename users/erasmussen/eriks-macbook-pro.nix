{ lib, ... }:
{
  imports = [ ./vscode/eriks-macbook-pro.nix ];

  options.dotfiles.eriksMacbookPro = lib.mkEnableOption "erasmussen's Eriks-MacBook-Pro profile";
}
