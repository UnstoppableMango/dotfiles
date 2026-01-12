{
  flake.modules.homeManager.k8s =
    { pkgs, ... }:
    {
      programs.k9s.enable = true;
      home.packages = with pkgs; [
        crc
        fluxcd
        kubernetes-helm
        kubectl
      ];
    };
}
