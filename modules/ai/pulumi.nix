{
  lib,
  config,
  ...
}:
let
  cfg = config.dotfiles.ai;

  mcpServer = {
    type = "http";
    url = "https://mcp.ai.pulumi.com/mcp";
  };
in
{
  options.dotfiles.ai.pulumi = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Pulumi MCP server for Claude Code and Copilot CLI.";
    };
  };

  config = lib.mkIf (cfg.enable && cfg.pulumi.enable) {
    programs.claude-code.mcpServers.pulumi = mcpServer;
    programs.github-copilot-cli.mcpServers.pulumi = mcpServer;
    programs.mcp.servers.pulumi = mcpServer;
  };
}
