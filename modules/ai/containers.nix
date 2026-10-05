{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.dotfiles.ai;

  mcpServer = {
    type = "stdio";
    command = "npx";
    args = [
      "-y"
      "podman-mcp-server@latest"
    ];
  };
in
{
  options.dotfiles.ai.containers = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Container MCP server support: podman-mcp-server, supporting both Podman and Docker (auto-detects the Podman socket, falls back to CLI). Installs Node.js; `mcp.enable` registers the server.";
    };

    mcp.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Register the MCP server. Every configured MCP server starts with each Claude Code and Copilot CLI session, so a project that wants this one declares it in a repo-local .mcp.json instead.";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf (cfg.enable && cfg.containers.enable) {
      home.packages = [ pkgs.nodejs ];
    })

    (lib.mkIf (cfg.enable && cfg.containers.enable && cfg.containers.mcp.enable) {
      programs.claude-code.mcpServers.containers = mcpServer;
      programs.github-copilot-cli.mcpServers.containers = mcpServer;
      programs.mcp.servers.containers = mcpServer;
    })
  ];
}
