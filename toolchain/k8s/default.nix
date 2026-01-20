let
  k8s =
    { pkgs, ... }:
    {
      programs.k9s.enable = true;

      home.packages = with pkgs; [
        fluxcd
        kubernetes-helm
        kubectl
        kubectl-get-all
        kubectl-get-resources
        kubectl-rook-ceph
      ];
    };

  krew =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      home.packages = [ pkgs.krew ];
      programs.zsh = lib.mkIf config.programs.zsh.enable {
        initContent = ''
          export PATH="''\${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
        '';
      };
    };

  openshift =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      options.openshift.enable = lib.mkEnableOption "OpenShift";

      config = lib.mkIf config.openshift.enable {
        home.packages = [
          pkgs.crc
          pkgs.openshift
        ];

        programs.zsh = lib.mkIf config.programs.zsh.enable {
          initContent = lib.mkAfter ''
            eval $(crc podman-env)
          '';
        };
      };
    };
in
{
  flake.homeModules = {
    inherit k8s krew openshift;
  };

  flake.modules.homeManager = {
    inherit k8s krew openshift;
  };
}
