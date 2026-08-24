{ clan-core }:
{
  overlays.default = final: prev: {
    inherit (clan-core.packages.${prev.stdenv.hostPlatform.system}) clan-cli;
  };
}
