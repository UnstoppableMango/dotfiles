{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.dotfiles.git.openCommit;

  # opencommit's own DEFAULT_CONFIG, mirrored. It only applies those defaults
  # when ~/.opencommit is absent: `getGlobalConfig` returns `ini.parse` of the
  # file verbatim once it exists, so a sparse file leaves OCO_MODEL and friends
  # undefined and the commit request goes out malformed. Rendering the file
  # therefore means rendering the whole config, not just the key.
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

  # `ini.stringify` output, which is what `oco config set` writes and
  # `ini.parse` reads back: bare `KEY=value`, one per line, no sections.
  rendered =
    lib.concatMapStrings (name: "${name}=${renderValue settings.${name}}\n") (lib.attrNames settings)
    + "OCO_API_KEY=${config.sops.placeholder.${cfg.apiKeySecret}}\n";

  # opencommit's model cache, a sibling of the config file and likewise fixed
  # at `join(homedir(), ...)`.
  cachePath = "${config.home.homeDirectory}/.opencommit-models.json";

  # `{ timestamp, models }` is the shape `writeCache` produces. The timestamp
  # is stamped at activation rather than at build time so the seed reads as
  # fresh for opencommit's 7 day CACHE_TTL_MS: `fetchModelsForProvider` takes a
  # valid cache as-is and refetches on its own once it expires, which is what a
  # real refresh would have left behind.
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

        # Curated overrides of upstream's defaults, at mkDefault so a host or a
        # consumer replaces any of them with a plain assignment.
        dotfiles.git.openCommit.settings = {
          # The conventional-commit prompt only forbids "a list of commit per
          # file change" when this is on. Off, nothing holds the model to one
          # subject and it emits a conventional-commit line per change.
          OCO_ONE_LINE_COMMIT = lib.mkDefault true;

          # Committing and pushing are separate decisions, and the hook fires
          # on every commit, including ones made mid-rebase.
          OCO_GITPUSH = lib.mkDefault false;

          # In hook mode oco otherwise prefixes the message with `# ` and asks
          # for the `#` to be removed in the editor. On, the draft lands ready
          # to use, which is also the only form that survives a commit that
          # never opens an editor.
          OCO_HOOK_AUTO_UNCOMMENT = lib.mkDefault true;
        };

        home.packages = [ pkgs.opencommit ];

        # oco detects "I'm running as a git hook" by checking that
        # process.argv[1] ends with `$(git config core.hooksPath)/prepare-commit-msg`.
        # nixpkgs' `bin/oco` is a bash wrapper that execs node with the store
        # path to cli.cjs as the script argument, which overwrites argv[1] and
        # breaks that detection. cli.cjs itself is unusable as the hook, since
        # its `#!/usr/bin/env node` shebang depends on PATH. The hook is a node
        # script that require()s cli.cjs instead, which keeps the hook path in
        # argv[1]. The test fails the build if nixpkgs moves cli.cjs, rather
        # than leaving a hook that cannot run.
        #
        # The exit handler applies typeEmoji once oco has written the draft.
        # It skips any commit with a source (-m, amend, merge, squash), which
        # is the same condition oco uses to skip generating.
        xdg.configFile."git/hooks/prepare-commit-msg".source =
          let
            cli = "${pkgs.opencommit}/lib/opencommit/cli.cjs";
            hook = pkgs.writeText "prepare-commit-msg.js" ''
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
          pkgs.runCommand "opencommit-prepare-commit-msg" { } ''
            test -f ${cli}
            { echo '#!${lib.getExe pkgs.nodejs}'; cat ${hook}; } > $out
            chmod +x $out
          '';

        # A global hooksPath rather than init.templateDir, because git copies a
        # template symlink's target, which pins a Home Manager generation that a
        # later GC removes. oco compares argv[1] against the raw config value,
        # so the path has to be absolute, without `~`.
        programs.git.settings.core.hooksPath = "${config.xdg.configHome}/git/hooks";
      }

      (lib.mkIf (cfg.apiKeySecret != null) {
        # ~/.opencommit, not an XDG path: `defaultConfigPath` is
        # `join(homedir(), ".opencommit")` with no override of any kind.
        sops.templates."opencommit" = {
          path = "${config.home.homeDirectory}/.opencommit";
          inherit (cfg) mode;
          content = rendered;
        };
      })

      (lib.mkIf (cfg.models != { }) {
        # The cache is opencommit's file: `oco models --refresh` has to keep
        # working, so this seeds an absent one and never touches it again.
        # `writeCache` swallows every error, so a store symlink here would fail
        # the refresh silently rather than loudly.
        home.activation.opencommitModelCache = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
          if [ ! -s ${lib.escapeShellArg cachePath} ]; then
            $DRY_RUN_CMD ${seedModelCache} ${lib.escapeShellArg cachePath}
          fi
        '';
      })
    ]
  );
}
