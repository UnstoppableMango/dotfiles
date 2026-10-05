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
      "@azure/mcp@latest"
      "server"
      "start"
    ];
  };
in
{
  options.dotfiles.ai.azure = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Azure MCP server support. Installs the Azure CLI and Node.js; `mcp.enable` registers the server, which authenticates via an existing `az login` session, no token in config.";
    };

    mcp.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Register the MCP server. Every configured MCP server starts with each Claude Code and Copilot CLI session, so a project that wants this one declares it in a repo-local .mcp.json instead.";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf (cfg.enable && cfg.azure.enable) {
      home.packages = [
        pkgs.azure-cli
        pkgs.nodejs
      ];
    })

    (lib.mkIf (cfg.enable && cfg.azure.enable && cfg.azure.mcp.enable) {
      programs.claude-code.mcpServers.azure = mcpServer;
      programs.github-copilot-cli.mcpServers.azure = mcpServer;
      programs.mcp.servers.azure = mcpServer;
    })
  ];
}
