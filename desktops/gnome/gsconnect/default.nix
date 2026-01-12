{
  flake.modules.homeManager.gsconnect =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        gnomeExtensions.gsconnect
        nautilus-python
      ];
    };
}
