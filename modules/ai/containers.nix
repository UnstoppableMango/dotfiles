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
      description = "Container MCP server for Claude Code and Copilot CLI: podman-mcp-server, supporting both Podman and Docker (auto-detects the Podman socket, falls back to CLI). Installs Node.js when enabled.";
    };
  };

  config = lib.mkIf (cfg.enable && cfg.containers.enable) {
    programs.claude-code.mcpServers.containers = mcpServer;
    programs.github-copilot-cli.mcpServers.containers = mcpServer;
    programs.mcp.servers.containers = mcpServer;

    home.packages = [ pkgs.nodejs ];
  };
}
