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
      "chrome-devtools-mcp@latest"
    ];
  };
in
{
  options.dotfiles.ai.chromeDevtools = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Official Chrome DevTools MCP server (Google): live DOM inspection, network requests, console errors, and performance traces for a Chrome instance it drives. No auth. Installs Node.js; `mcp.enable` registers the server.";
    };

    mcp.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Register the MCP server. Every configured MCP server starts with each Claude Code and Copilot CLI session, so a project that wants this one declares it in a repo-local .mcp.json instead.";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf (cfg.enable && cfg.chromeDevtools.enable) {
      home.packages = [ pkgs.nodejs ];
    })

    (lib.mkIf (cfg.enable && cfg.chromeDevtools.enable && cfg.chromeDevtools.mcp.enable) {
      programs.claude-code.mcpServers.chrome-devtools = mcpServer;
      programs.github-copilot-cli.mcpServers.chrome-devtools = mcpServer;
      programs.mcp.servers.chrome-devtools = mcpServer;
    })
  ];
}
