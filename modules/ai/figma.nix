{
  lib,
  config,
  ...
}:
let
  cfg = config.dotfiles.ai;

  mcpServer = {
    type = "http";
    url = "http://127.0.0.1:3845/mcp";
  };
in
{
  options.dotfiles.ai.figma = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Figma's Dev Mode MCP server. This only registers the client-side
        pointer at the fixed local address Figma's desktop app listens on;
        nothing to install. The server itself has to be started manually,
        each session, from Figma: Dev Mode > enable the MCP server toggle
        in the right sidebar. Without that running, connection just fails.
      '';
    };
  };

  config = lib.mkIf (cfg.enable && cfg.figma.enable) {
    programs.claude-code.mcpServers.figma-desktop = mcpServer;
    programs.github-copilot-cli.mcpServers.figma-desktop = mcpServer;
  };
}
