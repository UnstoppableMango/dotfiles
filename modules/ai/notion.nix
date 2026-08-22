{
  lib,
  config,
  ...
}:
let
  cfg = config.dotfiles.ai;

  mcpServer = {
    type = "http";
    url = "https://mcp.notion.com/mcp";
  };
in
{
  options.dotfiles.ai.notion = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Official Notion MCP server. OAuth via browser popup on first connect, no token in config.";
    };
  };

  config = lib.mkIf (cfg.enable && cfg.notion.enable) {
    programs.claude-code.mcpServers.notion = mcpServer;
    programs.github-copilot-cli.mcpServers.notion = mcpServer;
  };
}
