{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.dotfiles.ai;

  omnigentBin = "${config.home.homeDirectory}/.local/bin/omnigent";

  # omnigent's default, which every client assumes when no URL is configured.
  port = 6767;
  serverUrl = "http://127.0.0.1:${toString port}";

  # The uv venv's stdlib `ssl` loads zero CAs on NixOS (no /etc/ssl/cert.pem),
  # so wss:// fails CERTIFICATE_VERIFY_FAILED. requests ignores SSL_CERT_FILE.
  certEnv = {
    SSL_CERT_FILE = cfg.omnigent.caBundle;
    REQUESTS_CA_BUNDLE = cfg.omnigent.caBundle;
  };
  certEnvList = lib.mapAttrsToList (n: v: "${n}=${v}") certEnv;

  # https://omnigent.ai/download/mac redirects to the current versioned URL.
  omnigent-desktop = pkgs.stdenvNoCC.mkDerivation {
    pname = "omnigent-desktop";
    version = "0.10.0";
    src = pkgs.fetchurl {
      url = "https://diksk5m140cfbma7.public.blob.vercel-storage.com/mac/Omnigent-0.10.0-arm64.dmg";
      sha256 = "sha256-tfSV3R6k8P1Jib6RmCjwxFP/hQBtaBKFPQeisXTDdjU=";
    };
    nativeBuildInputs = [ pkgs.undmg ];
    sourceRoot = ".";
    installPhase = ''
      mkdir -p $out/Applications
      cp -pR *.app $out/Applications
    '';
  };
in
{
  imports =
    map
      (
        name:
        lib.mkRenamedOptionModule
          [ "dotfiles" "ai" "omnigent" "openRouter" name ]
          [ "dotfiles" "openrouter" "omnigent" name ]
      )
      [
        "enable"
        "default"
        "models"
      ]
    ++ [
      (lib.mkRenamedOptionModule
        [ "dotfiles" "ai" "omnigent" "openRouter" "apiKeySecret" ]
        [ "dotfiles" "openrouter" "apiKeySecret" ]
      )
    ];

  options.dotfiles.ai.omnigent = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };

    autostart = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Run omnigent as a login service (launchd on macOS, systemd user units on Linux) so the server at `listenAddress`:6767 is always up for the desktop, web, and mobile clients to connect to.";
    };

    listenAddress = lib.mkOption {
      type = lib.types.str;
      default = "127.0.0.1";
      example = "0.0.0.0";
      description = ''
        Interface the server binds. Loopback keeps it reachable only from this
        machine; `0.0.0.0` serves every IPv4 address the machine holds, so
        other devices reach the web UI at its LAN address or hostname.

        One address, not a list, and `::` is IPv6-only rather than dual-stack:
        omnigent's uvicorn socket sets IPV6_V6ONLY whatever the
        `net.ipv6.bindv6only` sysctl says.

        The server runs in header auth mode, which authenticates nothing, so
        whatever can reach the port can run agents on this machine as this
        user. Widen the bind only on a trusted network.

        Linux only: the launchd agent runs `omnigent start`, which hardcodes
        loopback.
      '';
    };

    caBundle = lib.mkOption {
      type = lib.types.str;
      default =
        if pkgs.stdenv.hostPlatform.isDarwin then
          "/etc/ssl/cert.pem"
        else
          "/etc/ssl/certs/ca-certificates.crt";
      description = ''
        CA bundle the server and host daemon verify TLS against, exported as
        both `SSL_CERT_FILE` and `REQUESTS_CA_BUNDLE`.

        The default is the system store. On NixOS that is where
        `security.pki.certificates` lands, so a private LAN CA declared there
        is trusted without being restated here. Point this at a
        `pkgs.cacert` path instead to limit the units to the public roots.
      '';
    };

    desktopApp = lib.mkOption {
      type = lib.types.bool;
      default = pkgs.stdenv.hostPlatform.isDarwin;
      description = "Install the Omnigent.app native desktop client. macOS (aarch64) only.";
    };
  };

  config = lib.mkIf (cfg.enable && cfg.omnigent.enable) (
    lib.mkMerge [
      {
        programs.uv.tool.packages = [ "omnigent" ];
      }

      (lib.mkIf (cfg.omnigent.autostart && pkgs.stdenv.hostPlatform.isDarwin) {
        launchd.agents.omnigent-server = {
          enable = true;
          config = {
            Label = "ai.omnigent.server";
            ProgramArguments = [
              omnigentBin
              "start"
            ];
            EnvironmentVariables = certEnv;
            RunAtLoad = true;
            KeepAlive = true;
            StandardOutPath = "${config.xdg.dataHome}/omnigent/server.log";
            StandardErrorPath = "${config.xdg.dataHome}/omnigent/server.log";
          };
        };
      })

      (lib.mkIf (cfg.omnigent.autostart && pkgs.stdenv.hostPlatform.isLinux) {
        # A separate server unit, because the server `omnigent host` spawns is
        # pinned to 127.0.0.1 (a literal in omnigent's host/local_server.py).
        systemd.user.services = {
          omnigent-server = {
            Unit.Description = "Omnigent server";
            Service = {
              # Without this the host daemon's tunnel registration gets a 403.
              Environment = [ "OMNIGENT_LOCAL_SINGLE_USER=1" ] ++ certEnvList;
              ExecStart = "%h/.local/bin/omnigent server --host ${cfg.omnigent.listenAddress} --port ${toString port}";
              Restart = "on-failure";
            };
            Install.WantedBy = [ "default.target" ];
          };

          omnigent-host = {
            Unit = {
              Description = "Omnigent host daemon";
              After = [ "omnigent-server.service" ];
              BindsTo = [ "omnigent-server.service" ];
            };
            Service = {
              # `--non-interactive` stops it stalling on the browser sign-in flow.
              Environment = certEnvList;
              ExecStart = "%h/.local/bin/omnigent host --server ${serverUrl} --non-interactive";
              # `After` does not wait for the server's socket.
              Restart = "on-failure";
              RestartSec = 5;
            };
            Install.WantedBy = [ "default.target" ];
          };
        };
      })

      (lib.mkIf (cfg.omnigent.desktopApp && pkgs.stdenv.hostPlatform.isDarwin) {
        # No notarization ticket: first launch needs right-click > Open.
        home.file."Applications/Omnigent.app".source = "${omnigent-desktop}/Applications/Omnigent.app";
      })
    ]
  );
}
