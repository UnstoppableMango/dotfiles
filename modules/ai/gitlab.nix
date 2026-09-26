{
  lib,
  config,
  ...
}:
let
  cfg = config.dotfiles.ai;

  mcpServer = {
    type = "http";
    url = "https://gitlab.com/api/v4/mcp";
  };
in
{
  options.dotfiles.ai.gitlab = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "GitLab MCP server for Claude Code and Copilot CLI.";
    };
  };

  config = lib.mkIf (cfg.enable && cfg.gitlab.enable) {
    programs.claude-code.mcpServers.gitlab = mcpServer;
    programs.github-copilot-cli.mcpServers.gitlab = mcpServer;
    programs.mcp.servers.gitlab = mcpServer;
  };
}
