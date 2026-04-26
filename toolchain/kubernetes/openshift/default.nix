{
  config,
  pkgs,
  lib,
  ...
}:
{
  options.dotfiles.openshift.enable = lib.mkEnableOption "OpenShift Toolchain";

  config = lib.mkIf config.dotfiles.openshift.enable {
    home.packages = with pkgs; [
      crc
      openshift
    ];

    programs.zsh = {
      initContent = ''
        eval $(crc podman-env)
      '';
    };
  };
}
