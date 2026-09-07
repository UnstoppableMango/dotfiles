{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.dotfiles.ai;

  jsonFormat = pkgs.formats.json { };

  configPath =
    if pkgs.stdenv.hostPlatform.isDarwin then
      "Library/Application Support/Claude/claude_desktop_config.json"
    else
      ".config/Claude/claude_desktop_config.json";

  headerArgs =
    headers:
    lib.concatLists (
      lib.mapAttrsToList (name: value: [
        "--header"
        "${name}: ${value}"
      ]) headers
    );

  # claude_desktop_config.json spawns subprocesses and speaks no HTTP, so a
  # remote server reaches the app through the mcp-remote stdio bridge.
  remoteServer = server: {
    command = "npx";
    args = [
      "-y"
      "mcp-remote"
      server.url
    ]
    ++ headerArgs server.headers;
  };

  localServer =
    name: server:
    lib.hm.mcp.transformMcpServer {
      inherit server;
      extraTransforms = [ (lib.hm.mcp.wrapEnvFilesCommand { inherit pkgs name; }) ];
      exclude = [
        "type"
        "enabled"
        "url"
        "headers"
      ];
    };

  toServer =
    name: server: if server.url != null then remoteServer server else localServer name server;

  servers = lib.mapAttrs toServer (
    lib.filterAttrs (_: server: server.enabled != false) config.programs.mcp.servers
  );
in
{
  options.dotfiles.ai.claudeDesktop = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = ''
        Render the Claude Desktop MCP config from `programs.mcp.servers`, so the
        per-service `dotfiles.ai.<tool>.enable` toggles configure the desktop app
        alongside Claude Code and Copilot CLI.

        The app itself is installed by hand (it has no nixpkgs package), so this
        configures software this module does not install, the same as
        `modules/onepassword`.
      '';
    };
  };

  config = lib.mkIf (cfg.enable && cfg.claudeDesktop.enable) {
    home.file.${configPath}.source = jsonFormat.generate "claude_desktop_config.json" {
      mcpServers = servers;
    };

    home.packages = [ pkgs.nodejs ];
  };
}
