{
  lib,
  config,
  ...
}:
let
  cfg = config.dotfiles.ai;

  mcpServer = {
    type = "http";
    url = "https://mcp.slack.com/mcp";
  };
in
{
  options.dotfiles.ai.slack = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Official Slack MCP server: search, messaging, canvases, and member info for a workspace. OAuth via browser popup, no token in config.";
    };
  };

  config = lib.mkIf (cfg.enable && cfg.slack.enable) {
    programs.claude-code.mcpServers.slack = mcpServer;
    programs.github-copilot-cli.mcpServers.slack = mcpServer;
  };
}
