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
      description = "Official Git MCP server (modelcontextprotocol/servers): local git operations as MCP tools. Installs `mcp-server-git`; `mcp.enable` registers the server. No --repository flag, since each tool call takes a repo_path at runtime rather than being pinned to one project.";
    };

    mcp.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Register the MCP server. Every configured MCP server starts with each Claude Code and Copilot CLI session, so a project that wants this one declares it in a repo-local .mcp.json instead.";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf (cfg.enable && cfg.gitMcp.enable) {
      home.packages = [ pkgs.mcp-server-git ];
    })

    (lib.mkIf (cfg.enable && cfg.gitMcp.enable && cfg.gitMcp.mcp.enable) {
      programs.claude-code.mcpServers.git = mcpServer;
      programs.github-copilot-cli.mcpServers.git = mcpServer;
      programs.mcp.servers.git = mcpServer;
    })
  ];
}
