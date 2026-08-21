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
      description = "Official Chrome DevTools MCP server (Google): live DOM inspection, network requests, console errors, and performance traces for a Chrome instance it drives. No auth.";
    };
  };

  config = lib.mkIf (cfg.enable && cfg.chromeDevtools.enable) {
    programs.claude-code.mcpServers.chrome-devtools = mcpServer;
    programs.github-copilot-cli.mcpServers.chrome-devtools = mcpServer;

    home.packages = [ pkgs.nodejs ];
  };
}
