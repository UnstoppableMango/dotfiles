{
  lib,
  flake-parts-lib,
  ...
}:
let
  inherit (lib)
    mkOption
    types
    ;
in
{
  options = {
    perSystem = flake-parts-lib.mkSubmoduleOptions {
      homeConfigurations = mkOption {
        type = types.lazyAttrsOf types.raw;
        default = { };
        description = ''
          Instantiated Home Manager configurations.

          `homeConfigurations` is for specific installations. If you want to expose
          reusable configurations, add them to `homeModules` in the form of modules, so
          that you can reference them in this or another flake's `homeConfigurations`.
        '';
      };
    };
  };
}
