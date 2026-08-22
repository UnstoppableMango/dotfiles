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
      "@playwright/mcp@latest"
    ];
  };
in
{
  options.dotfiles.ai.playwright = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Official Playwright MCP server (Microsoft): browser automation and testing. No auth.";
    };
  };

  config = lib.mkIf (cfg.enable && cfg.playwright.enable) {
    programs.claude-code.mcpServers.playwright = mcpServer;
    programs.github-copilot-cli.mcpServers.playwright = mcpServer;
    programs.mcp.servers.playwright = mcpServer;

    home.packages = [ pkgs.nodejs ];
  };
}
