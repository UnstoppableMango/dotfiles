{
  lib,
  config,
  ...
}:
let
  cfg = config.dotfiles.ai;
  inherit (cfg) crush;

  # Double quotes rather than lib.escapeShellArg: `programs.mcp.servers`
  # leaves `${VAR}` references for the reading client to expand, and in a
  # crushrc the client is a shell.
  quote = s: ''"${lib.escape [ "\\" "\"" "`" ] s}"'';

  flag = name: value: "--${name} ${quote value}";
  flags = name: map (flag name);
  pairs = name: lib.mapAttrsToList (k: v: "--${name} ${quote k} ${quote v}");

  command = words: lib.concatStringsSep " \\\n  " words;

  # Claude Code's LSP set is the one every language module under `ai/` fills,
  # so Crush follows it rather than each module registering a third time.
  lsp = lib.mapAttrsToList (
    name: server:
    command (
      [
        "lsp add ${lib.escapeShellArg name}"
        (flag "command" server.command)
      ]
      ++ flags "args" (server.args or [ ])
      ++ flags "filetypes" (lib.attrNames (server.extensionToLanguage or { }))
      ++ pairs "env" (server.env or { })
    )
  ) config.programs.claude-code.lspServers;

  mcp = lib.mapAttrsToList (
    name: raw:
    let
      # A `{ file = ...; }` env value becomes a command substitution, which
      # the double quotes leave for crushrc's shell to run.
      server = lib.hm.mcp.transformMcpServer {
        server = raw;
        extraTransforms = [ lib.hm.mcp.addType ];
        mkFileRef = path: "$(cat ${lib.escapeShellArg path})";
      };
    in
    command (
      [
        "mcp add ${lib.escapeShellArg name}"
        (flag "type" server.type)
      ]
      ++ (
        if server ? url then
          [ (flag "url" server.url) ]
          ++ pairs "header" (server.headers or { })
          ++ lib.optional (lib.elem name crush.oauthServers) "--oauth true"
        else
          [ (flag "command" server.command) ]
          ++ flags "args" (server.args or [ ])
          ++ pairs "env" (server.env or { })
      )
      ++ lib.optional ((server.enabled or true) == false) "--disabled true"
    )
  ) config.programs.mcp.servers;
in
{
  options.dotfiles.ai.crush = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Crush, Charm's terminal coding agent, with a crushrc carrying the LSP servers, MCP servers, and agent instructions the other agents get.";
    };

    oauthServers = lib.mkOption {
      type = with lib.types; listOf str;
      default = [
        "cloudflare-api"
        "cloudflare-bindings"
        "cloudflare-builds"
        "cloudflare-observability"
        "gitlab"
        "notion"
        "pulumi"
        "slack"
      ];
      description = ''
        `programs.mcp.servers` entries that sign in through a browser. Claude
        Code and Copilot CLI start that flow on a 401, but Crush only does so
        for a server marked `--oauth`, and with the mark it demands a token
        before connecting at all, so it cannot go on every HTTP server.
      '';
    };

    crushrc = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = ''
        Contents of `~/.config/crush/crushrc`, the Bash script Crush runs at
        startup. Integrations append to it; later lines win, so a host can
        override anything generated here with a plain definition.
      '';
    };
  };

  config = lib.mkIf (cfg.enable && crush.enable) {
    programs.crush.enable = true;

    # After the variables a `mkBefore` sets, before what integrations add.
    dotfiles.ai.crush.crushrc = lib.mkOrder 600 (
      lib.concatLines (
        [
          ''
            # Setting any global context path drops Crush's two defaults, so both
            # are listed again ahead of the instructions every agent shares.
            option global-context-path ${lib.escapeShellArg "${config.xdg.configHome}/crush/CRUSH.md"}
            option global-context-path ${lib.escapeShellArg "${config.xdg.configHome}/AGENTS.md"}
            option global-context-path ${./global-context.md}
          ''
        ]
        ++ lsp
        ++ mcp
      )
    );

    xdg.configFile."crush/crushrc".text = crush.crushrc;
  };
}
