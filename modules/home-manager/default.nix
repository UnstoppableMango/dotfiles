{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.dotfiles.homeManager;

  # Omitted when null so home-manager resolves the configuration itself,
  # `$USER@$HOSTNAME` first and `$USER` second.
  flakeRef = cfg.flakePath + lib.optionalString (cfg.configuration != null) "#${cfg.configuration}";

  backupArgs = lib.optionalString (cfg.backupExtension != null) "-b ${cfg.backupExtension}";

  homeup = pkgs.writeShellApplication {
    name = "homeup";
    runtimeInputs = [
      cfg.package
      pkgs.nix
    ];
    text = ''
      usage() {
        echo 'usage: homeup [-u] [home-manager switch options...]'
        echo
        echo 'Switch home-manager to ${flakeRef}.'
        echo
        echo '  -u, --update  run nix flake update first, which rewrites'
        echo '                flake.lock in the checkout'
        echo '  -h, --help    show this message'
        echo
        echo 'Any other argument is passed through to home-manager switch.'
      }

      update=0
      args=()

      for arg in "$@"; do
        case "$arg" in
        -u | --update) update=1 ;;
        -h | --help)
          usage
          exit 0
          ;;
        *) args+=("$arg") ;;
        esac
      done

      if [ ! -d '${cfg.flakePath}' ]; then
        echo 'homeup: ${cfg.flakePath} does not exist' >&2
        echo 'homeup: clone the dotfiles repo there, or set dotfiles.homeManager.flakePath' >&2
        exit 1
      fi

      set -x

      if [ "$update" -eq 1 ]; then
        nix flake update --flake '${cfg.flakePath}'
      fi

      exec home-manager switch --flake '${flakeRef}' ${backupArgs} "''${args[@]}"
    '';
  };
in
{
  options.dotfiles.homeManager = {
    enable = lib.mkEnableOption "the `homeup` command, a home-manager switch from a local checkout";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.home-manager;
      defaultText = lib.literalExpression "pkgs.home-manager";
      description = "The home-manager CLI `homeup` runs.";
    };

    flakePath = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory}/src/github.com/UnstoppableMango/dotfiles";
      defaultText = lib.literalExpression ''"''${config.home.homeDirectory}/src/github.com/UnstoppableMango/dotfiles"'';
      description = ''
        Absolute path to the checkout `homeup` switches from. Baked into the
        script, so the command works from any directory and in a shell with no
        environment.
      '';
    };

    configuration = lib.mkOption {
      type = with lib.types; nullOr str;
      default = null;
      description = ''
        Name of the home configuration to switch to, as the flake attribute.
        Null leaves it off the flake URI and lets home-manager resolve
        `$USER@$HOSTNAME`, which is the name every configuration here already
        has. A host whose hostname does not match one names it.
      '';
    };

    backupExtension = lib.mkOption {
      type = with lib.types; nullOr str;
      default = "hm-backup";
      description = ''
        Extension home-manager moves a colliding existing file to rather than
        failing the switch (`-b`). Null passes no `-b`, so a collision is an
        error.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [ homeup ];
  };
}
