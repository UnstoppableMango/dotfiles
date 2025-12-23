let
  erasmussen = {
    home.username = "erasmussen";
  };
in
{
  flake.homeModules = { inherit erasmussen; };
  flake.modules.homeManager = { inherit erasmussen; };

  perSystem = { pkgs, ... }: {
    homeConfigurations."erasmussen" = {
      inherit pkgs;

      modules = [ erasmussen ];
    };
  };
}
