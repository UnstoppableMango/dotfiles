{
  flake.modules.homeManager.cursor =
    { pkgs, ... }:
    {
      packages = with pkgs; [
        cursor-cli
      ];
    };
}
