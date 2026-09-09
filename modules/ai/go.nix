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
      description = "Go language support for Claude Code and Copilot CLI: gopls as the LSP server for .go files.";
    };

    mcp.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Register gopls's built-in (experimental) MCP server. Every configured MCP server starts with each Claude Code and Copilot CLI session regardless of the project's language, so a Go project declares this one in a repo-local .mcp.json instead.";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf (cfg.enable && cfg.go.enable) {
      programs.claude-code.lspServers.go = {
        command = gopls;
        args = [ "serve" ];
        extensionToLanguage = {
          ".go" = "go";
        };
      };

      programs.github-copilot-cli.lspServers.go = {
        command = gopls;
        args = [ "serve" ];
        fileExtensions = {
          ".go" = "go";
        };
      };

      home.packages = [ pkgs.gopls ];
    })

    (lib.mkIf (cfg.enable && cfg.go.enable && cfg.go.mcp.enable) {
      programs.claude-code.mcpServers.go = mcpServer;
      programs.mcp.servers.go = mcpServer;
      programs.github-copilot-cli.mcpServers.go = mcpServer;
    })
  ];
}
