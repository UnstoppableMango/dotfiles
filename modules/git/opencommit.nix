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

        home.packages = [ pkgs.opencommit ];

        # oco detects "I'm running as a git hook" by checking that
        # process.argv[1] ends with `$(git config core.hooksPath)/prepare-commit-msg`.
        # nixpkgs' `bin/oco` is a bash wrapper that execs node with the store
        # path to cli.cjs as the script argument, which overwrites argv[1] and
        # breaks that detection. Symlinking straight to cli.cjs preserves the
        # hook path in argv[1] instead. The test fails the build if nixpkgs
        # moves cli.cjs, rather than leaving a dangling hook.
        xdg.configFile."git/hooks/prepare-commit-msg".source =
          pkgs.runCommand "opencommit-prepare-commit-msg" { }
            ''
              test -f ${pkgs.opencommit}/lib/opencommit/cli.cjs
              ln -s ${pkgs.opencommit}/lib/opencommit/cli.cjs $out
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
    ]
  );
}
