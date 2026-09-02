{
  lib,
  config,
  ...
}:
{
  # self.nixvimModules.erik (./nixvim-config.nix) is a raw nixvim submodule,
  # not a home-manager module. It is a flake output so flake.nix's perSystem
  # can build a standalone `packages.nixvim` from the same configuration this
  # home module installs. modules/editors/neovim/default.nix stays fully
  # generic and never reaches into users/.
  config = lib.mkIf config.dotfiles.neovim.enable {
    programs.nixvim.imports = [ ./nixvim-config.nix ];
  };
}
