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
in
{
  options.dotfiles.ai.typescript = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "TypeScript/JavaScript language support for Claude Code and Copilot CLI: typescript-language-server as the LSP server, and lsmcp (wrapping the same server) as the MCP server. Installs Node.js when enabled.";
    };
  };

  config = lib.mkIf (cfg.enable && cfg.typescript.enable) {
    programs.claude-code = {
      lspServers.typescript = {
        command = tsserver;
        args = [ "--stdio" ];
        inherit extensionToLanguage;
      };
      mcpServers.typescript = {
        type = "stdio";
        command = "npx";
        args = [
          "-y"
          "@mizchi/lsmcp"
          "-p"
          "typescript"
        ];
      };
    };

    programs.github-copilot-cli = {
      lspServers.typescript = {
        command = tsserver;
        args = [ "--stdio" ];
        fileExtensions = extensionToLanguage;
      };
      mcpServers.typescript = {
        type = "stdio";
        command = "npx";
        args = [
          "-y"
          "@mizchi/lsmcp"
          "-p"
          "typescript"
        ];
      };
    };

    home.packages = [
      pkgs.typescript-language-server
      pkgs.nodejs
    ];
  };
}
