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
      "-y"
      "@brave/brave-search-mcp-server"
    ];
    env.BRAVE_API_KEY = "\${BRAVE_API_KEY}";
  };
in
{
  options.dotfiles.ai.braveSearch = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Official Brave Search MCP server. Needs a BRAVE_API_KEY exported in the shell (unset key means the server fails to start). Disabled by default.";
    };
  };

  config = lib.mkIf (cfg.enable && cfg.braveSearch.enable) {
    programs.claude-code.mcpServers.brave-search = mcpServer;
    programs.github-copilot-cli.mcpServers.brave-search = mcpServer;

    home.packages = [ pkgs.nodejs ];
  };
}
