# The slip flake exports packages and nothing else, so `slip` reaches `pkgs`
# the way clan-cli does rather than through an overlay of its own.
{ slip }:
{
  overlays.default = final: prev: {
    inherit (slip.packages.${prev.stdenv.hostPlatform.system}) slip;
  };
}
