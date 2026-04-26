{ pkgs, ... }:
{
  home.packages = with pkgs; [
    nil
    nixd
    nix-init
    nurl
  ];
}
