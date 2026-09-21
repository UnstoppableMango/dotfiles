{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.dotfiles.git.openCommit;

  # opencommit's DEFAULT_CONFIG, mirrored: `getGlobalConfig` applies none of it
  # once ~/.opencommit exists, so a sparse file sends a malformed request.
  defaultSettings = {
    OCO_AI_PROVIDER = "openai";
    OCO_MODEL = "gpt-4o-mini";
    OCO_TOKENS_MAX_INPUT = 4096;
    OCO_TOKENS_MAX_OUTPUT = 500;
    OCO_DESCRIPTION = false;
    OCO_EMOJI = false;
    OCO_LANGUAGE = "en";
    OCO_MESSAGE_TEMPLATE_PLACEHOLDER = "$msg";
    OCO_PROMPT_MODULE = "conventional-commit";
    OCO_ONE_LINE_COMMIT = false;
    OCO_WHY = false;
    OCO_OMIT_SCOPE = false;
    OCO_GITPUSH = true;
    OCO_HOOK_AUTO_UNCOMMENT = false;
  };

  settings = defaultSettings // cfg.settings;

  renderValue = value: if lib.isBool value then lib.boolToString value else toString value;

  # `ini.stringify` format: bare `KEY=value` lines, no sections.
  rendered =
    lib.concatMapStrings (name: "${name}=${renderValue settings.${name}}\n") (lib.attrNames settings)
    + "OCO_API_KEY=${config.sops.placeholder.${cfg.apiKeySecret}}\n";

  cachePath = "${config.home.homeDirectory}/.opencommit-models.json";

  # The shape `writeCache` produces, stamped at activation so it counts as
  # fresh for the 7 day CACHE_TTL_MS.
  seedModelCache = pkgs.writeShellScript "opencommit-seed-models" ''
    set -euo pipefail
    exec ${lib.getExe pkgs.jq} -n \
      --argjson models ${lib.escapeShellArg (builtins.toJSON cfg.models)} \
      '{ timestamp: (now * 1000 | floor), models: $models }' > "$1"
  '';
in
{
  options.dotfiles.git.openCommit = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        opencommit (`oco`) as a global `prepare-commit-msg` hook: git's
        `core.hooksPath` points at `~/.config/git/hooks`, where the hook links
        to opencommit's cli script, so every repo gets commit messages drafted
        from the staged diff in Conventional Commit form. A global
        `core.hooksPath` makes git ignore each repo's `.git/hooks`; a repo that
        needs its own hooks sets `core.hooksPath` locally, which takes
        precedence. Needs an OCO_API_KEY (or a local OCO_AI_PROVIDER such as
        ollama) exported in the shell, or `apiKeySecret` set to have one
        rendered into `~/.opencommit` by sops-nix. Disabled by default.
      '';
    };

    apiKeySecret = lib.mkOption {
      type = with lib.types; nullOr str;
      default = null;
      description = ''
        Name of a `sops.secrets` entry holding the API key. When set,
        `~/.opencommit` is rendered through `sops.templates` with the key
        substituted in, which is the only supply route that also covers git
        invoked outside a login shell (editor and GUI commits), since the
        `OCO_API_KEY` environment variable is not in reach there.

        The declaration itself is identity-scoped, so it lives under `home/`;
        this module only names it. Null leaves `~/.opencommit` unmanaged and
        the key has to come from the environment instead.
      '';
    };

    settings = lib.mkOption {
      type =
        with lib.types;
        attrsOf (oneOf [
          bool
          int
          str
        ]);
      default = { };
      example = {
        OCO_AI_PROVIDER = "anthropic";
        OCO_MODEL = "claude-sonnet-4-6";
      };
      description = ''
        Entries for `~/.opencommit`, merged over opencommit's own defaults.
        Only consulted when `apiKeySecret` is set, since that is what puts
        this module in charge of the file. `OCO_API_KEY` is supplied from the
        secret and cannot be set here.
      '';
    };

    mode = lib.mkOption {
      type = lib.types.str;
      default = "0600";
      description = ''
        Mode of the rendered `~/.opencommit`. Owner-writable by default:
        interactive `oco` runs migrations that rewrite the file, and 0400
        would fail them. Those writes land on the sops runtime copy and are
        discarded at the next activation, which is the intent.
      '';
    };

    models = lib.mkOption {
      type = with lib.types; attrsOf (listOf str);
      default = { };
      example = {
        anthropic = [
          "claude-haiku-4-5-20251001"
          "claude-sonnet-5"
        ];
      };
      description = ''
        Seed for `~/.opencommit-models.json`, keyed by `OCO_AI_PROVIDER` value.
        opencommit only writes that file from `oco models --refresh`, so a host
        that has never run one falls back to the MODEL_LIST baked into the
        package, which lags the provider's `/v1/models` by months, and `oco
        models` then names models that no longer exist alongside none of the
        current ones. The seed is written only when the file is absent or
        empty, leaving the refresh in charge from then on. Empty leaves the
        cache unmanaged.

        `OCO_MODEL` itself is not constrained by any of this: opencommit
        validates it as a string and nothing more, so a model missing from both
        lists still reaches the provider.
      '';
    };
  };

  config = lib.mkIf (config.dotfiles.git.enable && cfg.enable) (
    lib.mkMerge [
      {
        assertions = [
          {
            assertion = cfg.apiKeySecret == null || config.sops.secrets ? ${cfg.apiKeySecret};
            message = ''
              dotfiles.git.openCommit.apiKeySecret names "${toString cfg.apiKeySecret}",
              which is not declared in sops.secrets. sops-nix resolves
              placeholders against that set, so the template would render the
              literal placeholder string as the API key.
            '';
          }
          {
            assertion = !(cfg.settings ? OCO_API_KEY);
            message = ''
              dotfiles.git.openCommit.settings must not set OCO_API_KEY: it
              would put the key in the world-readable nix store. Use
              apiKeySecret instead.
            '';
          }
        ];

        dotfiles.git.openCommit.settings = {
          # Off, the model emits one conventional-commit line per file change.
          OCO_ONE_LINE_COMMIT = lib.mkDefault true;

          # The hook fires on every commit, including mid-rebase.
          OCO_GITPUSH = lib.mkDefault false;

          # Off, hook mode prefixes the draft with `# `, which a commit that
          # never opens an editor discards.
          OCO_HOOK_AUTO_UNCOMMENT = lib.mkDefault true;
        };

        home.packages = [ pkgs.opencommit ];

        # oco detects hook mode by argv[1] ending in
        # `$(git config core.hooksPath)/prepare-commit-msg`, which nixpkgs'
        # `bin/oco` wrapper overwrites, so the hook require()s cli.cjs instead.
        xdg.configFile."git/hooks/prepare-commit-msg".source =
          let
            cli = "${pkgs.opencommit}/lib/opencommit/cli.cjs";
          in
          pkgs.runCommand "opencommit-prepare-commit-msg" { } ''
            test -f ${cli}
            cat > $out <<'EOF'
            #!${lib.getExe pkgs.nodejs}
            require("${cli}");
            EOF
            chmod +x $out
          '';

        # oco compares argv[1] against the raw value, so no `~`. Not
        # init.templateDir: git copies a symlink's target, pinning a generation.
        programs.git.settings.core.hooksPath = "${config.xdg.configHome}/git/hooks";
      }

      (lib.mkIf (cfg.apiKeySecret != null) {
        # `defaultConfigPath` is fixed at `join(homedir(), ".opencommit")`.
        sops.templates."opencommit" = {
          path = "${config.home.homeDirectory}/.opencommit";
          inherit (cfg) mode;
          content = rendered;
        };
      })

      (lib.mkIf (cfg.models != { }) {
        # Not a store symlink: `writeCache` swallows errors, so the refresh
        # would fail silently.
        home.activation.opencommitModelCache = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          if [ ! -s ${lib.escapeShellArg cachePath} ]; then
            $DRY_RUN_CMD ${seedModelCache} ${lib.escapeShellArg cachePath}
          fi
        '';
      })
    ]
  );
}
