# The zettelkasten flake exports packages and nothing else, so `slip` reaches
# `pkgs` the way clan-cli does rather than through an overlay of its own.
{ zettelkasten }:
{
  overlays.default = final: prev: {
    inherit (zettelkasten.packages.${prev.stdenv.hostPlatform.system}) slip;
  };
}
