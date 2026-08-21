{
  lib,
  config,
  ...
}:
let
  cfg = config.dotfiles.ai;

  mcpServer = {
    type = "http";
    url = "https://mcp.deepwiki.com/mcp";
  };
in
{
  options.dotfiles.ai.deepwiki = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "DeepWiki MCP server: structured, wiki-style documentation and Q&A for any public GitHub repository. Free, no auth.";
    };
  };

  config = lib.mkIf (cfg.enable && cfg.deepwiki.enable) {
    programs.claude-code.mcpServers.deepwiki = mcpServer;
    programs.github-copilot-cli.mcpServers.deepwiki = mcpServer;
  };
}
