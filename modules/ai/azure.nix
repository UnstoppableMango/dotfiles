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
      description = "Azure MCP server for Claude Code and Copilot CLI. Installs the Azure CLI and Node.js when enabled; authenticates via an existing `az login` session, no token in config.";
    };
  };

  config = lib.mkIf (cfg.enable && cfg.azure.enable) {
    programs.claude-code.mcpServers.azure = mcpServer;
    programs.github-copilot-cli.mcpServers.azure = mcpServer;

    home.packages = [
      pkgs.azure-cli
      pkgs.nodejs
    ];
  };
}
