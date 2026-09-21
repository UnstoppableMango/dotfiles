# The slip flake exports no overlay.
{ slip }:
{
  overlays.default = final: prev: {
    inherit (slip.packages.${prev.stdenv.hostPlatform.system}) slip;
  };
}
