{
  flake.modules.homeManager.cursor =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        cursor-cli
      ];
    };
}
