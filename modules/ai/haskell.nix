{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.dotfiles.ai;

  hls = lib.getExe' pkgs.haskellPackages.haskell-language-server "haskell-language-server-wrapper";

  extensionToLanguage = {
    ".hs" = "haskell";
  };

  mcpServer = {
    type = "stdio";
    command = "npx";
    args = [
      "-y"
      "@mizchi/lsmcp"
      "-p"
      "hls"
    ];
  };
in
{
  options.dotfiles.ai.haskell = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Haskell language support for Claude Code and Copilot CLI: haskell-language-server as the LSP server for .hs files. Installs Node.js when enabled.";
    };

    mcp.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Register lsmcp (wrapping haskell-language-server) as an MCP server. Every configured MCP server starts with each Claude Code and Copilot CLI session regardless of the project's language, so a Haskell project declares this one in a repo-local .mcp.json instead.";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf (cfg.enable && cfg.haskell.enable) {
      programs.claude-code.lspServers.haskell = {
        command = hls;
        args = [ "--lsp" ];
        inherit extensionToLanguage;
      };

      programs.github-copilot-cli.lspServers.haskell = {
        command = hls;
        args = [ "--lsp" ];
        fileExtensions = extensionToLanguage;
      };

      home.packages = [
        pkgs.haskellPackages.haskell-language-server
        pkgs.nodejs
      ];
    })

    (lib.mkIf (cfg.enable && cfg.haskell.enable && cfg.haskell.mcp.enable) {
      programs.claude-code.mcpServers.haskell = mcpServer;
      programs.mcp.servers.haskell = mcpServer;
      programs.github-copilot-cli.mcpServers.haskell = mcpServer;
    })
  ];
}
