{
  flake.modules.homeManager.containers =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        docker
        podman
        podman-compose
        podman-tui
        buildah
      ];
    };

  flake.modules.nixos.containers =
    { pkgs, ... }:
    {
      virtualisation = {
        docker = {
          enable = true;
          storageDriver = "btrfs";

          daemon.settings = {
            userland-proxy = false;
          };

          rootless = {
            enable = true;
            setSocketVariable = true;
          };
        };

        podman.enable = true;
      };
    };
}
