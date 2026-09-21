# The zettelkasten flake exports no overlay.
{ zettelkasten }:
{
  overlays.default = final: prev: {
    inherit (zettelkasten.packages.${prev.stdenv.hostPlatform.system}) slip;
  };
}
