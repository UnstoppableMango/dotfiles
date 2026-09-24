{
  lib,
  config,
  pkgs,
  ...
}:
let
  cfg = config.dotfiles.github.token;

  secret =
    if cfg.secret == null then
      throw "dotfiles.github.token.file needs dotfiles.github.token.secret set."
    else if !(config.sops.secrets ? ${cfg.secret}) then
      throw ''dotfiles.github.token.secret names "${cfg.secret}", which is not declared in sops.secrets.''
    else
      cfg.secret;

  # GitHub reports a fine-grained PAT's expiry in a response header on every
  # authenticated request, so the date never has to be copied into nix.
  expiryCheck = pkgs.writeShellApplication {
    name = "github-token-expiry";
    runtimeInputs = with pkgs; [
      coreutils
      curl
      gnugrep
      libnotify
    ];
    text = ''
      notify() {
        notify-send --app-name=github-token "$@" || true
      }

      # Headers go through stdin so the token never shows in a process listing.
      headers=$(printf 'Authorization: Bearer %s\n' "$(cat '${cfg.file}')" \
        | curl -sS -o /dev/null -D - -H @- https://api.github.com/user)

      status=$(head -n1 <<<"$headers" | cut -d' ' -f2)
      if [ "$status" = 401 ]; then
        echo "GitHub token rejected (401): revoked or expired" >&2
        notify -u critical "GitHub token expired" "Run github-token-rotate."
        exit 1
      fi
      if [ "$status" != 200 ]; then
        echo "GitHub API returned $status" >&2
        exit 1
      fi

      expiry=$(grep -i '^github-authentication-token-expiration:' <<<"$headers" | cut -d' ' -f2- | tr -d '\r' || true)
      if [ -z "$expiry" ]; then
        echo "GitHub token has no expiration"
        exit 0
      fi

      days=$(( ($(date -d "$expiry" +%s) - $(date +%s)) / 86400 ))
      echo "GitHub token expires $expiry ($days days)"
      if [ "$days" -lt ${toString cfg.warnDays} ]; then
        notify "GitHub token expires in $days days" "Run github-token-rotate before $expiry."
      fi
    '';
  };

  rotate = pkgs.writeShellApplication {
    name = "github-token-rotate";
    runtimeInputs = with pkgs; [
      coreutils
      curl
      jq
      sops
      xdg-utils
    ];
    text = ''
      url=https://github.com/settings/personal-access-tokens/new
      echo "Create a fine-grained token at $url"
      xdg-open "$url" >/dev/null 2>&1 || true

      read -rsp 'New token: ' token
      echo

      status=$(printf 'Authorization: Bearer %s\n' "$token" \
        | curl -sS -o /dev/null -w '%{http_code}' -H @- https://api.github.com/user)
      if [ "$status" != 200 ]; then
        echo "github-token-rotate: GitHub rejected the token ($status)" >&2
        exit 1
      fi

      # sops finds .sops.yaml by searching upward from the working directory.
      cd '${cfg.flakePath}'
      if [ -f '${cfg.sopsFile}' ]; then
        jq -R . <<<"$token" | sops set --value-stdin '${cfg.sopsFile}' '["${cfg.sopsKey}"]'
      else
        tmp=$(mktemp)
        jq -R '{"${cfg.sopsKey}": .}' <<<"$token" \
          | sops encrypt --filename-override '${cfg.sopsFile}' --input-type json --output-type yaml /dev/stdin \
          >"$tmp"
        mv "$tmp" '${cfg.sopsFile}'
      fi

      echo "Updated ${cfg.flakePath}/${cfg.sopsFile}."
      echo "Next: run homeup, restart open claude/copilot sessions, then revoke the old token on GitHub."
    '';
  };
in
{
  options.dotfiles.github.token = {
    secret = lib.mkOption {
      type = with lib.types; nullOr str;
      default = null;
      description = ''
        Name of a `sops.secrets` entry holding a GitHub personal access token.
        Setting it turns on the expiry check and `github-token-rotate`, and
        exports the token to the GitHub MCP server's clients.
      '';
    };

    file = lib.mkOption {
      type = lib.types.str;
      readOnly = true;
      default = config.sops.secrets.${secret}.path;
      defaultText = lib.literalExpression "config.sops.secrets.\${config.dotfiles.github.token.secret}.path";
      description = "Decrypted token path, for integrations to read.";
    };

    flakePath = lib.mkOption {
      type = lib.types.str;
      default = config.dotfiles.homeManager.flakePath;
      defaultText = lib.literalExpression "config.dotfiles.homeManager.flakePath";
      description = "Checkout holding the sops file `github-token-rotate` writes.";
    };

    sopsFile = lib.mkOption {
      type = lib.types.str;
      default = "home/secrets/github.yaml";
      description = "Path of the encrypted token file, relative to `flakePath`.";
    };

    sopsKey = lib.mkOption {
      type = lib.types.str;
      default = "github_pat";
      description = "Key inside `sopsFile` holding the token.";
    };

    warnDays = lib.mkOption {
      type = lib.types.ints.positive;
      default = 14;
      description = "Days before expiry at which the check starts sending a desktop notification.";
    };

    onCalendar = lib.mkOption {
      type = lib.types.str;
      default = "daily";
      description = "systemd OnCalendar expression for the expiry check.";
    };
  };

  config = lib.mkIf (cfg.secret != null) (
    lib.mkMerge [
      { home.packages = [ rotate ]; }

      # home-manager's systemd.user.* options are Linux-only.
      (lib.mkIf pkgs.stdenv.hostPlatform.isLinux {
        systemd.user.services.github-token-expiry = {
          Unit = {
            Description = "Check the GitHub token's expiry";
            After = [ "sops-nix.service" ];
          };
          Service = {
            Type = "oneshot";
            ExecStart = lib.getExe expiryCheck;
          };
        };

        systemd.user.timers.github-token-expiry = {
          Unit.Description = "Timer for github-token-expiry.service";
          Timer = {
            OnCalendar = cfg.onCalendar;
            Persistent = true;
          };
          Install.WantedBy = [ "timers.target" ];
        };
      })
    ]
  );
}
