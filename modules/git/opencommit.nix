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

  # Stable path the template hook execs, so it follows the current generation.
  hookEntry = "git/opencommit-hook";
  hookPath = "${config.xdg.configHome}/${hookEntry}";

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
        opencommit (`oco`) as a `prepare-commit-msg` hook in every repo git
        creates: `init.templateDir` puts the hook in `.git/hooks` on `git init`
        and `git clone`, so commit messages are drafted from the staged diff in
        Conventional Commit form. An existing repo picks the hook up from a
        `git init` inside it, which leaves hooks already present alone. A repo
        whose hook manager defines its own `prepare-commit-msg`, or sets a
        local `core.hooksPath` the way husky does, goes without it. Needs an OCO_API_KEY (or a local OCO_AI_PROVIDER such as ollama)
        exported in the shell, or `apiKeySecret` set to have one rendered into
        `~/.opencommit` by sops-nix. Disabled by default.
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

    typeEmoji = lib.mkOption {
      type = with lib.types; attrsOf str;
      default = {
        feat = "✨";
        fix = "🐛";
        docs = "📝";
        style = "🎨";
        refactor = "♻️";
        perf = "⚡️";
        test = "✅";
        build = "📦️";
        ci = "👷";
        chore = "🔧";
        revert = "⏪️";
        deps = "⬆️";
      };
      description = ''
        Emoji the hook inserts after a generated message's Conventional
        Commit prefix, keyed by type, so `feat(git): add x` becomes
        `feat(git): ✨ add x`. A type missing here is left alone, and an
        empty set turns the rewrite off.

        This is done in the hook rather than with `OCO_EMOJI`, because that
        setting swaps the conventional-commit prompt for a GitMoji one that
        drops the type entirely.
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
            assertion = cfg.typeEmoji == { } || !(cfg.settings.OCO_EMOJI or false);
            message = ''
              dotfiles.git.openCommit.settings.OCO_EMOJI replaces the
              conventional-commit prompt with a GitMoji one that has no type
              prefix, so typeEmoji has nothing to attach to. Leave OCO_EMOJI
              off, or set typeEmoji = { } to use GitMoji alone.
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

        # oco detects hook mode by argv[1] ending in `.git/hooks/prepare-commit-msg`,
        # which nixpkgs' `bin/oco` wrapper overwrites, so the hook passes its own
        # path ($0) back into argv[1] before require()ing cli.cjs. The exit
        # handler applies typeEmoji, skipping commits with a source as oco does.
        xdg.configFile.${hookEntry}.source =
          let
            cli = "${pkgs.opencommit}/lib/opencommit/cli.cjs";
            hook = pkgs.writeText "opencommit-hook.js" ''
              process.argv.splice(1, 2, process.argv[2]);
              const typeEmoji = ${builtins.toJSON cfg.typeEmoji};
              const [file, source] = process.argv.slice(2);
              if (file && !source && Object.keys(typeEmoji).length > 0) {
                process.on("exit", () => {
                  const fs = require("fs");
                  const [title, ...rest] = fs.readFileSync(file, "utf8").split("\n");
                  const m = title.match(/^(\w+)(\([^)]*\))?(!?): (.*)$/);
                  const emoji = m && Object.hasOwn(typeEmoji, m[1]) && typeEmoji[m[1]];
                  if (!emoji || m[4].startsWith(emoji)) return;
                  const newTitle = `''${m[1]}''${m[2] ?? ""}''${m[3]}: ''${emoji} ''${m[4]}`;
                  fs.writeFileSync(file, [newTitle, ...rest].join("\n"));
                });
              }
              require("${cli}");
            '';
          in
          pkgs.runCommand "opencommit-hook" { } ''
            test -f ${cli}
            { echo '#!${lib.getExe pkgs.nodejs}'; cat ${hook}; } > $out
            chmod +x $out
          '';

        # Not a global core.hooksPath, which lefthook and similar tools install
        # into. Git copies a template symlink as a symlink, so the template is a
        # store directory of regular files.
        programs.git.settings.init.templateDir = toString (
          pkgs.writeTextFile {
            name = "git-template";
            destination = "/hooks/prepare-commit-msg";
            executable = true;
            text = ''
              #!/bin/sh
              hook=${lib.escapeShellArg hookPath}
              [ -x "$hook" ] || exit 0
              exec "$hook" "$0" "$@"
            '';
          }
        );
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
