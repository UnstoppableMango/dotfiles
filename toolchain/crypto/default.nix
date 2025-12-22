let
  crypto =
    { pkgs, ... }:
    {
      home.packages = [ pkgs.openssl ];
    };
in
{
  flake.homeModules = { inherit crypto; };
  flake.modules.homeManager = { inherit crypto; };
}
