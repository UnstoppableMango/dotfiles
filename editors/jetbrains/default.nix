{ config, pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    jetbrains.webstorm
    jetbrains.rust-rover
    jetbrains.ruby-mine
    jetbrains.rider
    jetbrains.idea-ultimate
    jetbrains.goland
    jetbrains.datagrip
    jetbrains.clion
  ];

  fonts.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
  ];
}
