{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.dotfiles.containers.enable = lib.mkEnableOption "container Toolchain";
  options.dotfiles.containers.podmanAutostart = lib.mkEnableOption "podman machine autostart";

  config = lib.mkIf config.dotfiles.containers.enable {
    home.packages = with pkgs; [
      buildah
      docker
      podman
      podman-compose
      podman-tui
      skopeo
    ];

    launchd.agents = lib.mkIf config.dotfiles.containers.podmanAutostart {
      podman-machine = {
        enable = true;
        config = {
          Label = "io.podman.machine.start";
          RunAtLoad = true;
          ProgramArguments = [
            "${pkgs.podman}/bin/podman"
            "machine"
            "start"
          ];
          StandardOutPath = "${config.xdg.dataHome}/containers/podman/machine/podman-machine.log";
          StandardErrorPath = "${config.xdg.dataHome}/containers/podman/machine/podman-machine.log";
        };
      };
    };
  };
}
