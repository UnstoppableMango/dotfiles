{ lib, ... }:
let
  # One directory per piece of software, imported by existing rather than by
  # being listed. The category layer this replaced (`editors/`, `terminals/`,
  # `toolchain/`, ...) forced a "which bucket?" decision with no correct
  # answer, and the hand-written import lists that went with it were a second
  # place to forget a module.
  #
  # A subdirectory is a module when it has a `default.nix`. Anything else here
  # (a skill's agents, a config fragment) is ignored, which is why the check is
  # on the file rather than on the directory alone.
  isModule = name: type: type == "directory" && builtins.pathExists (./. + "/${name}/default.nix");
in
{
  imports = lib.mapAttrsToList (name: _: ./. + "/${name}") (
    lib.filterAttrs isModule (builtins.readDir ./.)
  );
}
