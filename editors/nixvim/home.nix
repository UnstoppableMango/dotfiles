{ ... }:
{
  programs.nixvim = {
    enable = true;
    defaultEditor = true;

    inherit (import ./module.nix) plugins;
  };
}
