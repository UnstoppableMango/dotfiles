{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.dotfiles.ai;

  omnigentBin = "${config.home.homeDirectory}/.local/bin/omnigent";

  omnigentHome = "${config.home.homeDirectory}/.omnigent";
  configPath = "${omnigentHome}/config.yaml";

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

  openRouter = cfg.omnigent.openRouter;

  # OpenRouter reaches the OpenAI-compatible Chat Completions surface at its
  # own base URL. The openai family's default endpoint (api.openai.com) is
  # wrong for it, and it implements no Responses API, so both fields are
  # required rather than left to the consuming harness.
  openRouterEntry = {
    kind = "key";
    openai = {
      base_url = "https://openrouter.ai/api/v1";
      wire_api = "chat";
      # A shell command that prints the token, rather than `api_key_ref:
      # env:OPENROUTER_API_KEY`: the systemd user unit below never sees a
      # login shell, so an environment variable is not in reach there.
      auth_command = "cat ${config.sops.secrets.${openRouter.apiKeySecret}.path}";
    }
    // lib.optionalAttrs (openRouter.models != { }) { inherit (openRouter) models; };
  }
  // lib.optionalAttrs openRouter.default { default = true; };

  providerFragment = (pkgs.formats.yaml { }).generate "omnigent-providers.yaml" {
    providers.openrouter = openRouterEntry;
  };

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

    openRouter = {
      enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
        description = ''
          OpenRouter as an omnigent model provider, registered under
          `providers.openrouter` in `~/.omnigent/config.yaml`. It serves the
          `openai` family, which is what the codex, opencode, qwen, and
          openai-agents harnesses consume. Needs `apiKeySecret` set.
          Disabled by default.
        '';
      };

      apiKeySecret = lib.mkOption {
        type = with lib.types; nullOr str;
        default = null;
        description = ''
          Name of a `sops.secrets` entry holding the OpenRouter API key. The
          provider entry reads it with an `auth_command`, so the key stays out
          of both the nix store and the environment, and resolves the same way
          for the systemd user unit as for an interactive shell.

          The declaration itself is identity-scoped, so it lives under
          `users/`; this module only names it.
        '';
      };

      default = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = ''
          Mark the entry `default: true`, making OpenRouter the default for
          every surface it serves: the `openai` family and the `pi` scope. A
          `claude` subscription entry claims the `anthropic` family only, so
          the two coexist. omnigent rejects a config where two providers claim
          the same family.
        '';
      };

      models = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = { };
        example = {
          default = "anthropic/claude-sonnet-4.5";
        };
        description = ''
          Role or tier to OpenRouter model id. The `default` entry is
          consulted when an agent spec pins no model of its own; without it
          `/model` reports no pinned model and `omnigent config set --global
          model=...` supplies one instead.
        '';
      };
    };
  };

  config = lib.mkIf (cfg.enable && cfg.omnigent.enable) (
    lib.mkMerge [
      {
        programs.uv.tool.packages = [ "omnigent" ];

        assertions = [
          {
            assertion = !openRouter.enable || openRouter.apiKeySecret != null;
            message = ''
              dotfiles.ai.omnigent.openRouter.enable needs apiKeySecret set:
              the provider entry has no other credential route, and a family
              with no api_key/api_key_ref/auth_command fails omnigent's own
              parse.
            '';
          }
          {
            assertion =
              !openRouter.enable
              || openRouter.apiKeySecret == null
              || config.sops.secrets ? ${openRouter.apiKeySecret};
            message = ''
              dotfiles.ai.omnigent.openRouter.apiKeySecret names
              "${toString openRouter.apiKeySecret}", which is not declared in
              sops.secrets, so there is no decrypted path for the
              auth_command to read.
            '';
          }
        ];
      }

      # Guarded on apiKeySecret too, not just enable: the entry's
      # auth_command indexes sops.secrets by that name, so a null would throw
      # before the assertion above got a chance to report it.
      (lib.mkIf (openRouter.enable && openRouter.apiKeySecret != null) {
        # `~/.omnigent/config.yaml` is runtime-owned: omnigent generates
        # `host.host_id` there on first `omnigent host`, and `omnigent config
        # set --global` rewrites the whole file. So the nix-declared entry is
        # merged in rather than the file being rendered outright. Assigning
        # `.providers.openrouter` (not a deep merge) means nix fully owns that
        # one entry while every sibling survives untouched.
        home.activation.omnigentProviders = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          $DRY_RUN_CMD mkdir -p ${lib.escapeShellArg omnigentHome}
          $DRY_RUN_CMD touch ${lib.escapeShellArg configPath}
          $DRY_RUN_CMD ${pkgs.yq-go}/bin/yq -i \
            '.providers.openrouter = load("${providerFragment}").providers.openrouter' \
            ${lib.escapeShellArg configPath}
        '';
      })

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
