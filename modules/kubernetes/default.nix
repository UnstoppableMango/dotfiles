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
    ./rosequartz
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
      # Provides kubectl-oidc_login, the plugin the rosequartz OIDC context
      # shells out to as `kubectl oidc-login`.
      kubelogin-oidc
    ];

    programs.zsh.initContent = lib.mkIf config.dotfiles.zsh.enable ''
      export PATH="''\${KREW_ROOT:-$HOME/.krew}/bin:$PATH"
    '';
  };
}
