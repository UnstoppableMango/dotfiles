{ tdl }:
{
  overlays.default = final: prev: {
    tdl = tdl.packages.${prev.stdenv.hostPlatform.system}.default;
  };
}
