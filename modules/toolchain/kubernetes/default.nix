{
  pkgs,
  lib,
  config,
  ...
}:
{
  imports = [
    ./k9s
    ./openshift
  ];

  options.dotfiles.kubernetes.enable = lib.mkEnableOption "Kubernetes Toolchain";

  config = lib.mkIf config.dotfiles.kubernetes.enable {
    home.packages = with pkgs; [
      fluxcd
      krew
      kubernetes-helm
      kubectl
      kubectl-get-all
      kubectl-get-resources
      kubectl-rook-ceph
    ];

    programs.zsh = {
      initContent = ''
        export PATH="''\${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
      '';
    };
  };
}
