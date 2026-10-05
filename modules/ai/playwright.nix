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
      description = "Official Playwright MCP server (Microsoft): browser automation and testing. No auth. Installs Node.js; `mcp.enable` registers the server.";
    };

    mcp.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Register the MCP server. Every configured MCP server starts with each Claude Code and Copilot CLI session, so a project that wants this one declares it in a repo-local .mcp.json instead.";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf (cfg.enable && cfg.playwright.enable) {
      home.packages = [ pkgs.nodejs ];
    })

    (lib.mkIf (cfg.enable && cfg.playwright.enable && cfg.playwright.mcp.enable) {
      programs.claude-code.mcpServers.playwright = mcpServer;
      programs.github-copilot-cli.mcpServers.playwright = mcpServer;
      programs.mcp.servers.playwright = mcpServer;
    })
  ];
}
