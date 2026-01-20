let
  k8s =
    {
      config,
      pkgs,
      lib,
      ...
    }:
    {
      options.openshift.enable = lib.mkEnableOption "OpenShift";

      config = {
        programs.k9s.enable = true;

        home.packages =
          with pkgs;
          [
            fluxcd
            kubernetes-helm
            kubectl
            kubectl-rook-ceph
          ]
          ++ (lib.lists.optionals config.openshift.enable (
            with pkgs;
            [
              crc
              openshift
            ]
          ));

        programs.zsh = lib.mkIf config.programs.zsh.enable {
          initContent = lib.mkIf config.openshift.enable (
            lib.mkAfter ''
              eval $(crc podman-env)
            ''
          );
        };
      };
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
in
{
  flake.homeModules = {
    inherit k8s krew;
  };

  flake.modules.homeManager = {
    inherit k8s krew;
  };
}
