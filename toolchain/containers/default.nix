{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.dotfiles.containers.enable = lib.mkEnableOption "container Toolchain";

  config = lib.mkIf config.dotfiles.containers.enable {
    home.packages = with pkgs; [
      buildah
      docker
      podman
      podman-compose
      podman-tui
      skopeo
    ];
  };
}
