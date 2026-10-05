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
      description = "Kubernetes MCP server support: containers/kubernetes-mcp-server, run read-only against the current kubeconfig context. Installs Node.js; `mcp.enable` registers the server.";
    };

    mcp.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Register the MCP server. Every configured MCP server starts with each Claude Code and Copilot CLI session, so a project that wants this one declares it in a repo-local .mcp.json instead.";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf (cfg.enable && cfg.kubernetes.enable) {
      home.packages = [ pkgs.nodejs ];
    })

    (lib.mkIf (cfg.enable && cfg.kubernetes.enable && cfg.kubernetes.mcp.enable) {
      programs.claude-code.mcpServers.kubernetes = mcpServer;
      programs.github-copilot-cli.mcpServers.kubernetes = mcpServer;
      programs.mcp.servers.kubernetes = mcpServer;
    })
  ];
}
