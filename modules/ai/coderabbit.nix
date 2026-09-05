{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.dotfiles.ai;
  coderabbit = cfg.coderabbit;

  # `~/.coderabbit` is the CLI's own state directory: auth.json alongside
  # doctor.json, logs/, reviews/, skills.json, and stats.json, all of which the
  # binary owns. Only auth.json is declared here.
  authPath = "${config.home.homeDirectory}/.coderabbit/auth.json";

  # What `coderabbit auth login --api-key <key>` writes. The api_key branch of
  # the CLI's auth reader returns the file verbatim rather than consulting the
  # OS credential store, which the OAuth branch does for its access and refresh
  # tokens, so this file on its own is a complete authenticated state.
  authFile = builtins.toJSON {
    type = "api_key";
    apiKey = "@apiKey@";
    inherit (coderabbit) region;
  };
in
{
  options.dotfiles.ai.coderabbit = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        CodeRabbit CLI (`coderabbit`, aliased `cr`): AI code review of local
        changes from the terminal, with `--agent`/`--prompt-only` output modes
        another agent can consume.
      '';
    };

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.coderabbit;
      defaultText = lib.literalExpression "pkgs.coderabbit";
      description = ''
        The CodeRabbit CLI package. Not in nixpkgs, so this flake's overlay
        supplies it from the upstream release zip.
      '';
    };

    apiKeySecret = lib.mkOption {
      type = with lib.types; nullOr str;
      default = null;
      description = ''
        Name of a `sops.secrets` entry holding an agentic CodeRabbit API key
        (Settings > API Keys; a user API key is rejected by the CLI). When set,
        `~/.coderabbit/auth.json` is rendered through `sops.templates` with the
        key substituted in, so the CLI is authenticated without an interactive
        `coderabbit auth login` and without the key reaching the nix store.

        The CLI reads no `CODERABBIT_API_KEY` environment variable, so the file
        is the only non-interactive supply route short of passing `--api-key`
        on every `review`.

        The secret declaration itself is identity-scoped and lives under
        `home/`; this module only names it. Null leaves auth.json unmanaged and
        authentication happens through `coderabbit auth login`.
      '';
    };

    region = lib.mkOption {
      type = lib.types.enum [
        "us"
        "eu"
      ];
      default = "us";
      description = ''
        CodeRabbit data region the API key belongs to, recorded in auth.json.
        Matches the CLI's own default when unset.
      '';
    };

    autoUpdate = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Let the CLI update itself. Off by default: `coderabbit update` rewrites
        the binary in place, which for a nix-installed one means writing into
        the read-only store, and a successful update would in any case be
        reverted by the next activation. Bump `pkgs/coderabbit.nix` instead.
      '';
    };
  };

  config = lib.mkIf (cfg.enable && coderabbit.enable) (
    lib.mkMerge [
      {
        home.packages = [ coderabbit.package ];

        home.sessionVariables = lib.mkIf (!coderabbit.autoUpdate) {
          CODERABBIT_CLI_DISABLE_AUTO_UPDATE = "1";
        };

        assertions = [
          {
            assertion = coderabbit.apiKeySecret == null || config.sops.secrets ? ${coderabbit.apiKeySecret};
            message = ''
              dotfiles.ai.coderabbit.apiKeySecret names
              "${toString coderabbit.apiKeySecret}", which is not declared in
              sops.secrets, so there is no key to render into auth.json.
            '';
          }
        ];
      }

      (lib.mkIf (coderabbit.apiKeySecret != null) {
        sops.templates."coderabbit-auth.json" = {
          content =
            lib.replaceStrings
              [ "@apiKey@" ]
              [
                config.sops.placeholder.${coderabbit.apiKeySecret}
              ]
              authFile;
          path = authPath;
          mode = "0600";
        };
      })
    ]
  );
}
