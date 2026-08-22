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
    command = lib.getExe pkgs.mcp-server-git;
  };
in
{
  options.dotfiles.ai.gitMcp = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Official Git MCP server (modelcontextprotocol/servers): local git operations as MCP tools. No --repository flag, since each tool call takes a repo_path at runtime rather than being pinned to one project.";
    };
  };

  config = lib.mkIf (cfg.enable && cfg.gitMcp.enable) {
    programs.claude-code.mcpServers.git = mcpServer;
    programs.github-copilot-cli.mcpServers.git = mcpServer;
    programs.mcp.servers.git = mcpServer;

    home.packages = [ pkgs.mcp-server-git ];
  };
}
