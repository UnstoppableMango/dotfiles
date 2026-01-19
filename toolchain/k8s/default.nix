{
  flake.modules.homeManager.k8s =
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
}
