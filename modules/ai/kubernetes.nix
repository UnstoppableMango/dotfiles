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
      "kubernetes-mcp-server@latest"
      "--read-only"
    ];
  };
in
{
  options.dotfiles.ai.kubernetes = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Kubernetes MCP server for Claude Code and Copilot CLI: containers/kubernetes-mcp-server, run read-only against the current kubeconfig context. Installs Node.js when enabled.";
    };
  };

  config = lib.mkIf (cfg.enable && cfg.kubernetes.enable) {
    programs.claude-code.mcpServers.kubernetes = mcpServer;
    programs.github-copilot-cli.mcpServers.kubernetes = mcpServer;
    programs.mcp.servers.kubernetes = mcpServer;

    home.packages = [ pkgs.nodejs ];
  };
}
