{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.dotfiles.slip;

  toml = pkgs.formats.toml { };

  # Guarded rather than interpolated directly: `path` is nullable, and mkIf
  # does not stop the value it wraps from being evaluated.
  notebookDir = lib.optionalString (
    cfg.notebook.path != null
  ) "${config.home.homeDirectory}/${cfg.notebook.path}";
in
{
  options.dotfiles.slip = {
    enable = lib.mkEnableOption "slip, a zettelkasten capture tool";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.slip;
      defaultText = lib.literalExpression "pkgs.slip";
      description = ''
        The slip package. The slip flake exports packages and no
        overlay, so this flake's own overlay adapts them (`overlays/slip.nix`).

        The default build wraps `zk` onto slip's PATH, which is what makes
        `slip list` and the rest of the passthrough work.
      '';
    };

    notebook = {
      path = lib.mkOption {
        type = with lib.types; nullOr str;
        default = "notes";
        description = ''
          Directory holding the notes, relative to the home directory, exported
          as `ZK_NOTEBOOK_DIR`.

          Relative rather than absolute because nix2git resolves a repository
          path against the home directory, and one value has to serve both.

          Null exports nothing and declares no repository, leaving slip on its
          own fallback of `$XDG_DATA_HOME/zettelkasten`.
        '';
      };

      init = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = ''
          Declare {option}`notebook.path` as a nix2git repository, so a machine
          that does not have it yet gets a `git init` at activation.

          nix2git creates a repository only where none exists, and never
          clones, rewrites, or deletes, so this is safe alongside a corpus
          cloned by hand.
        '';
      };
    };

    zk.settings = lib.mkOption {
      type = toml.type;
      default = {
        format.markdown.frontmatter.creation-date-key = "create_time";
      };
      description = ''
        zk's global configuration, written to `~/.config/zk/config.toml`. A
        notebook's own `.zk/config.toml` inherits from it.

        The default is the one setting that makes zk read a note's creation
        time from slip's `create_time` frontmatter rather than falling back to
        the file's mtime. It is what `slip init` appends to a notebook, so
        declaring it globally covers every notebook at once and keeps the
        setting out of a notes repository's history.
      '';
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        home.packages = [ cfg.package ];
      }

      (lib.mkIf (cfg.zk.settings != { }) {
        xdg.configFile."zk/config.toml".source = toml.generate "zk-config.toml" cfg.zk.settings;
      })

      (lib.mkIf (cfg.notebook.path != null) {
        # ZK_NOTEBOOK_DIR rather than slip's own ZK_DIR, because zk honours this
        # one too. One variable aims both halves of the passthrough at the same
        # corpus; ZK_DIR would move slip and leave zk walking up from the cwd.
        home.sessionVariables.ZK_NOTEBOOK_DIR = notebookDir;

        nix2git = lib.mkIf cfg.notebook.init {
          enable = true;
          repositories.${cfg.notebook.path} = { };
        };
      })
    ]
  );
}
