{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.dotfiles.ai;

  tsserver = lib.getExe pkgs.typescript-language-server;

  extensionToLanguage = {
    ".ts" = "typescript";
    ".tsx" = "typescriptreact";
    ".js" = "javascript";
    ".jsx" = "javascriptreact";
  };

  mcpServer = {
    type = "stdio";
    command = "npx";
    args = [
      "-y"
      "@mizchi/lsmcp"
      "-p"
      "typescript"
    ];
  };
in
{
  options.dotfiles.ai.typescript = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "TypeScript/JavaScript language support for Claude Code and Copilot CLI: typescript-language-server as the LSP server. Installs Node.js when enabled.";
    };

    mcp.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Register lsmcp (wrapping typescript-language-server) as an MCP server. Every configured MCP server starts with each Claude Code and Copilot CLI session regardless of the project's language, so a TypeScript project declares this one in a repo-local .mcp.json instead.";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf (cfg.enable && cfg.typescript.enable) {
      programs.claude-code.lspServers.typescript = {
        command = tsserver;
        args = [ "--stdio" ];
        inherit extensionToLanguage;
      };

      programs.github-copilot-cli.lspServers.typescript = {
        command = tsserver;
        args = [ "--stdio" ];
        fileExtensions = extensionToLanguage;
      };

      home.packages = [
        pkgs.typescript-language-server
        pkgs.nodejs
      ];
    })

    (lib.mkIf (cfg.enable && cfg.typescript.enable && cfg.typescript.mcp.enable) {
      programs.claude-code.mcpServers.typescript = mcpServer;
      programs.mcp.servers.typescript = mcpServer;
      programs.github-copilot-cli.mcpServers.typescript = mcpServer;
    })
  ];
}
