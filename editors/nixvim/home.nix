{ ... }:
{
  programs.nixvim = {
    enable = true;
    inherit (import ./module.nix) plugins;
  };
}
