{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.dotfiles.containers;
  inherit (config.home) homeDirectory;
in
{
  options.dotfiles.containers = {
    enable = lib.mkEnableOption "container Toolchain";

    podmanAutostart = lib.mkEnableOption "podman machine autostart";

    podmanSocket = lib.mkOption {
      type = lib.types.bool;
      default = pkgs.stdenv.isLinux && config.targets.genericLinux.enable;
      defaultText = lib.literalExpression "pkgs.stdenv.isLinux && config.targets.genericLinux.enable";
      description = ''
        Run the rootless podman API socket as a user systemd unit.
        Defaults on for non-NixOS Linux, where nothing else supplies the unit.
        NixOS hosts get `virtualisation.podman.dockerSocket`/`podman.socket` from
        the system layer, and defining it here would collide with that.
      '';
    };

    sharedAuth = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Point podman, skopeo, and buildah at docker's `~/.docker/config.json`
        through `REGISTRY_AUTH_FILE`, so one `docker login` covers both stacks
        instead of each keeping its own credential file.
      '';
    };

    userRegistryConfig = lib.mkOption {
      type = lib.types.bool;
      default = pkgs.stdenv.isLinux && config.targets.genericLinux.enable;
      defaultText = lib.literalExpression "pkgs.stdenv.isLinux && config.targets.genericLinux.enable";
      description = ''
        Write `policy.json` and `registries.conf` under `~/.config/containers`.
        The podman package carries no defaults of its own and reads them from
        `/etc/containers`, which only exists on hosts whose system layer sets up
        containers. Off on NixOS so the system files stay authoritative.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    # docker-client rather than docker: the daemon is a system service that
    # Home Manager cannot start, so the user profile carries the CLI only and
    # talks to whatever dockerd the host runs.
    home.packages = with pkgs; [
      buildah
      docker-buildx
      docker-client
      docker-compose
      podman
      podman-compose
      podman-tui
      skopeo
    ];

    # `docker compose` and `docker buildx` resolve as CLI plugins, not as the
    # standalone binaries on PATH, and docker-client ships neither.
    home.file = {
      ".docker/cli-plugins/docker-buildx".source =
        "${pkgs.docker-buildx}/libexec/docker/cli-plugins/docker-buildx";
      ".docker/cli-plugins/docker-compose".source =
        "${pkgs.docker-compose}/libexec/docker/cli-plugins/docker-compose";
    };

    home.sessionVariables = lib.mkIf cfg.sharedAuth {
      REGISTRY_AUTH_FILE = "${homeDirectory}/.docker/config.json";
    };

    xdg.configFile = lib.mkIf cfg.userRegistryConfig {
      "containers/policy.json".text = builtins.toJSON {
        default = [ { type = "insecureAcceptAnything"; } ];
      };

      "containers/registries.conf".text = ''
        unqualified-search-registries = ["docker.io", "ghcr.io", "quay.io"]
      '';
    };

    systemd.user = lib.mkIf cfg.podmanSocket {
      sockets.podman = {
        Unit.Description = "Podman API socket";
        Socket = {
          ListenStream = "%t/podman/podman.sock";
          SocketMode = "0660";
        };
        Install.WantedBy = [ "sockets.target" ];
      };

      services.podman = {
        Unit = {
          Description = "Podman API service";
          Requires = [ "podman.socket" ];
          After = [ "podman.socket" ];
        };
        Service = {
          Type = "exec";
          KillMode = "process";
          Environment = "LOGGING=--log-level=info";
          ExecStart = "${pkgs.podman}/bin/podman $LOGGING system service --time=0";
        };
        Install.Also = [ "podman.socket" ];
      };
    };

    launchd.agents = lib.mkIf cfg.podmanAutostart {
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
