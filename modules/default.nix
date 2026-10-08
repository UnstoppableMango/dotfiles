{ lib, ... }:
let
  # Subdirectories without a `default.nix` (a skill's agents, a config
  # fragment) are not modules.
  isModule = name: type: type == "directory" && builtins.pathExists (./. + "/${name}/default.nix");
in
{
  imports = lib.mapAttrsToList (name: _: ./. + "/${name}") (
    lib.filterAttrs isModule (builtins.readDir ./.)
  );
}
