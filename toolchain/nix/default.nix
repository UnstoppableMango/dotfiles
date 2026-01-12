{
  flake.modules.homeManager.nix =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        nil
        nixd
        nix-init
        nurl
      ];
    };
}
