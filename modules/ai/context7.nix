{
  lib,
  config,
  ...
}:
let
  cfg = config.dotfiles.ai;

  mcpServer = {
    type = "http";
    url = "https://mcp.context7.com/mcp";
  };
in
{
  options.dotfiles.ai.context7 = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Context7 MCP server: live, version-specific library documentation lookups. Anonymous rate limit, no API key configured; add a CONTEXT7_API_KEY header here for higher limits if needed.";
    };
  };

  config = lib.mkIf (cfg.enable && cfg.context7.enable) {
    programs.claude-code.mcpServers.context7 = mcpServer;
    programs.github-copilot-cli.mcpServers.context7 = mcpServer;
  };
}
