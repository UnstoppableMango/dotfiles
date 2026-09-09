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
      description = "Rust language support for Claude Code and Copilot CLI: rust-analyzer as the LSP server for .rs files.";
    };

    mcp.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Register rust-analyzer-mcp as an MCP server. Every configured MCP server starts with each Claude Code and Copilot CLI session regardless of the project's language, so a Rust project declares this one in a repo-local .mcp.json instead.";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf (cfg.enable && cfg.rust.enable) {
      programs.claude-code.lspServers.rust = {
        command = rustAnalyzer;
        extensionToLanguage = {
          ".rs" = "rust";
        };
      };

      programs.github-copilot-cli.lspServers.rust = {
        command = rustAnalyzer;
        fileExtensions = {
          ".rs" = "rust";
        };
      };

      home.packages = [
        pkgs.rust-analyzer
        pkgs.rust-analyzer-mcp
      ];
    })

    (lib.mkIf (cfg.enable && cfg.rust.enable && cfg.rust.mcp.enable) {
      programs.claude-code.mcpServers.rust = mcpServer;
      programs.mcp.servers.rust = mcpServer;
      programs.github-copilot-cli.mcpServers.rust = mcpServer;
    })
  ];
}
