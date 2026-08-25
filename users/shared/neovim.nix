{ lib, config, ... }:
{
  # Personal LSP/plugin config lives in ./nixvim-config.nix (a raw nixvim
  # submodule, not a home-manager module) rather than being wired in from
  # modules/editors/neovim/default.nix, which stays fully generic and never
  # reaches into users/. flake.nix's perSystem also builds a standalone
  # nixvim package directly from ./nixvim-config.nix.
  config = lib.mkIf config.dotfiles.neovim.enable {
    programs.nixvim.imports = [ ./nixvim-config.nix ];
  };
}
