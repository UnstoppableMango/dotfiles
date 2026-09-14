{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.dotfiles.ai;

  omnigentBin = "${config.home.homeDirectory}/.local/bin/omnigent";

  # omnigent's own default, and what every client assumes when no URL is
  # configured, so it stays a constant rather than an option.
  port = 6767;
  serverUrl = "http://127.0.0.1:${toString port}";

  # omnigent runs out of a uv-managed venv, so its TLS trust comes either from
  # certifi (httpx, requests) or from OpenSSL's compiled-in defaults
  # (websockets, and anything else on stdlib `ssl`). Neither reaches the
  # system store on NixOS: `/etc/ssl/cert.pem` does not exist and
  # `/etc/ssl/certs` carries no hashed symlinks, so `create_default_context()`
  # loads zero CAs and every wss:// handshake the host daemon opens fails
  # CERTIFICATE_VERIFY_FAILED. certifi's own bundle covers the public roots
  # but never `security.pki.certificates` additions, so a host behind a
  # private CA still fails on the paths that do work.
  #
  # One bundle carries both, so both env vars point at it. SSL_CERT_FILE
  # redirects stdlib ssl and httpx; requests consults REQUESTS_CA_BUNDLE
  # alone and ignores the former.
  certEnv = {
    SSL_CERT_FILE = cfg.omnigent.caBundle;
    REQUESTS_CA_BUNDLE = cfg.omnigent.caBundle;
  };
  certEnvList = lib.mapAttrsToList (n: v: "${n}=${v}") certEnv;

  # No nixpkgs package or Homebrew cask exists for the desktop client, so the
  # .dmg is fetched and unpacked directly. Bump version + sha256 together when
  # updating: https://omnigent.ai/download/mac redirects to the versioned URL.
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
  # The OpenRouter provider entry lives in modules/openrouter/omnigent.nix.
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
        # Two units rather than one `omnigent host`: left to itself the host
        # daemon spawns the server as a child pinned to 127.0.0.1, an argv
        # literal in omnigent's host/local_server.py that no flag, config key,
        # or environment variable reaches. Running `omnigent server` as its own
        # unit is what makes the bind address selectable; the daemon then
        # attaches to it over loopback instead of spawning its own.
        systemd.user.services = {
          omnigent-server = {
            Unit.Description = "Omnigent server";
            Service = {
              # The server the host daemon spawns is marked as this user's
              # single-user local runtime. Without the same mark here the
              # daemon's tunnel registration is refused with a 403.
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
              # Loopback whatever the server binds, since both units are the
              # same machine. `--non-interactive` keeps a daemon with no
              # terminal from stalling on the browser sign-in flow.
              Environment = certEnvList;
              ExecStart = "%h/.local/bin/omnigent host --server ${serverUrl} --non-interactive";
              # `After` orders the start but does not wait for the socket, so
              # the first attempt can beat the server to it.
              Restart = "on-failure";
              RestartSec = 5;
            };
            Install.WantedBy = [ "default.target" ];
          };
        };
      })

      (lib.mkIf (cfg.omnigent.desktopApp && pkgs.stdenv.hostPlatform.isDarwin) {
        # Symlinked straight from the nix store, so the bundle carries no
        # quarantine/notarization ticket - first launch needs a right-click >
        # Open to get past Gatekeeper.
        home.file."Applications/Omnigent.app".source = "${omnigent-desktop}/Applications/Omnigent.app";
      })
    ]
  );
}
