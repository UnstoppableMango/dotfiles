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
        if crc status 2>/dev/null | grep -q "Running"; then
          eval $(crc podman-env)
        fi
      '';
    };
  };
}
