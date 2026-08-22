{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.dotfiles.ai;

  rustAnalyzer = lib.getExe pkgs.rust-analyzer;
  rustAnalyzerMcp = lib.getExe pkgs.rust-analyzer-mcp;

  mcpServer = {
    type = "stdio";
    command = rustAnalyzerMcp;
  };
in
{
  options.dotfiles.ai.rust = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Rust language support for Claude Code and Copilot CLI: rust-analyzer as the LSP server for .rs files, and rust-analyzer-mcp as the MCP server.";
    };
  };

  config = lib.mkIf (cfg.enable && cfg.rust.enable) {
    programs.claude-code = {
      lspServers.rust = {
        command = rustAnalyzer;
        extensionToLanguage = {
          ".rs" = "rust";
        };
      };
      mcpServers.rust = mcpServer;
    };

    programs.mcp.servers.rust = mcpServer;

    programs.github-copilot-cli = {
      lspServers.rust = {
        command = rustAnalyzer;
        fileExtensions = {
          ".rs" = "rust";
        };
      };
      mcpServers.rust = mcpServer;
    };

    home.packages = [
      pkgs.rust-analyzer
      pkgs.rust-analyzer-mcp
    ];
  };
}
