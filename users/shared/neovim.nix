{
  lib,
  config,
  ...
}:
{
  # self.nixvimModules.erik (./nixvim-config.nix) is a raw nixvim submodule,
  # not a home-manager module, exposed as a flake output so it's the single
  # shareable nixvim configuration both erik and erasmussen consume here, and
  # flake.nix's perSystem also builds its standalone `packages.nixvim` from.
  # modules/editors/neovim/default.nix stays fully generic and never reaches
  # into users/.
  config = lib.mkIf config.dotfiles.neovim.enable {
    programs.nixvim.imports = [ ./nixvim-config.nix ];
  };
}
