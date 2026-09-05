{
  overlays.default = final: _prev: {
    coderabbit = final.callPackage ../pkgs/coderabbit.nix { };
  };
}
