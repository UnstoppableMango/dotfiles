{
  lib,
  pkgs,
  config,
  ...
}:
let
  cfg = config.dotfiles.ai;
  rc = cfg.remoteControl;

  flags = [
    "--spawn"
    rc.spawn
    "--permission-mode"
    rc.permissionMode
  ]
  ++ lib.optionals (rc.name != null) [
    "--name"
    (lib.escapeShellArg rc.name)
  ];

  # Each makes Remote Control refuse to start (they disable the feature-flag
  # evaluation it depends on, or point away from api.anthropic.com).
  ineligibilityVars = [
    "DO_NOT_TRACK"
    "DISABLE_TELEMETRY"
    "DISABLE_GROWTHBOOK"
    "CLAUDE_CODE_DISABLE_NONESSENTIAL_TRAFFIC"
    "ANTHROPIC_BASE_URL"
  ];
in
{
  options.dotfiles.ai.remoteControl = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Run the Claude Code Remote Control server as a systemd user service,
        so sessions on this machine stay reachable from claude.ai/code and the
        Claude mobile apps without a terminal being open.

        The server registers with Anthropic over outbound HTTPS and opens no
        inbound port. Execution and filesystem access stay on this machine;
        the transcript of a connected session is stored on Anthropic servers
        while it is connected.

        Requires a Claude subscription login (`claude` then `/login`) and one
        `claude` run in `rootDir` to accept the workspace trust dialog. Linux
        only, matching home-manager's `systemd.user` options.
      '';
    };

    rootDir = lib.mkOption {
      type = lib.types.str;
      default = "${config.home.homeDirectory}/${cfg.checkoutRoot.path}";
      defaultText = lib.literalExpression ''"''${config.home.homeDirectory}/''${config.dotfiles.ai.checkoutRoot.path}"'';
      example = "/home/erik/src/github.com/UnstoppableMango/dotfiles";
      description = ''
        Working directory of the server, and so of the session it pre-creates.
        The checkout root by default, which puts every repository under it in
        reach of one session and picks up the `AGENTS.md` written there.
      '';
    };

    name = lib.mkOption {
      type = with lib.types; nullOr str;
      default = null;
      example = "hades";
      description = ''
        Session title shown in the session list at claude.ai/code. Null, the
        default, leaves Claude Code to generate one from the hostname, like
        `hades-graceful-unicorn`.
      '';
    };

    spawn = lib.mkOption {
      type = lib.types.enum [
        "same-dir"
        "worktree"
        "session"
      ];
      default = "same-dir";
      description = ''
        How the server creates sessions. `same-dir` gives every session
        `rootDir`, so concurrent sessions can conflict over the same files.
        `worktree` isolates each on-demand session in its own git worktree and
        requires `rootDir` to be a git repository, which a checkout root is
        not. `session` serves exactly one session and exits when it ends,
        which `Restart` then restarts.
      '';
    };

    permissionMode = lib.mkOption {
      type = lib.types.enum [
        "default"
        "plan"
        "acceptEdits"
        "auto"
        "dontAsk"
        "bypassPermissions"
      ];
      default = "default";
      example = "acceptEdits";
      description = ''
        Starting permission mode for the sessions the server spawns. `default`
        prompts for each permission, which has to be answered from whatever
        device is connected. `bypassPermissions` prompts for nothing, so
        anything signed into the account can run any command under `rootDir`
        as this user.
      '';
    };
  };

  config = lib.mkIf (cfg.enable && rc.enable && pkgs.stdenv.hostPlatform.isLinux) {
    systemd.user.services.claude-remote-control = {
      Unit = {
        Description = "Claude Code Remote Control server";
        Documentation = [ "https://code.claude.com/docs/en/remote-control" ];
        After = [ "network-online.target" ];
        Wants = [ "network-online.target" ];
        # Ineligibility fails identically every attempt; the systemd default
        # limit (5 starts per 10s) never trips at RestartSec=10.
        StartLimitIntervalSec = 300;
        StartLimitBurst = 5;
      };

      Service = {
        WorkingDirectory = rc.rootDir;
        UnsetEnvironment = ineligibilityVars;

        # A user unit inherits no login shell PATH.
        Environment = [
          "PATH=${config.home.profileDirectory}/bin:/run/wrapper/bin:/run/current-system/sw/bin"
        ];

        # No `--continue`: it errors when no session ran in the last four
        # hours, turning `Restart` into a crash loop.
        ExecStart = lib.concatStringsSep " " (
          [
            (lib.getExe config.programs.claude-code.finalPackage)
            "remote-control"
          ]
          ++ flags
        );

        # stdout is a repainting status panel (about 30MB a day); failures go
        # to stderr.
        StandardOutput = "null";
        StandardError = "journal";

        Restart = "always";
        RestartSec = 10;
      };

      Install.WantedBy = [ "default.target" ];
    };
  };
}
