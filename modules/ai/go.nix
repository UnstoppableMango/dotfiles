{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.dotfiles.ai;

  gopls = lib.getExe pkgs.gopls;

  mcpServer = {
    type = "stdio";
    command = gopls;
    args = [ "mcp" ];
  };
in
{
  options.dotfiles.ai.go = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Go language support for Claude Code and Copilot CLI: gopls as the LSP server for .go files, and gopls's built-in (experimental) MCP server.";
    };
  };

  config = lib.mkIf (cfg.enable && cfg.go.enable) {
    programs.claude-code = {
      lspServers.go = {
        command = gopls;
        args = [ "serve" ];
        extensionToLanguage = {
          ".go" = "go";
        };
      };
      mcpServers.go = mcpServer;
    };

    programs.mcp.servers.go = mcpServer;

    programs.github-copilot-cli = {
      lspServers.go = {
        command = gopls;
        args = [ "serve" ];
        fileExtensions = {
          ".go" = "go";
        };
      };
      mcpServers.go = mcpServer;
    };

    home.packages = [ pkgs.gopls ];
  };
}
