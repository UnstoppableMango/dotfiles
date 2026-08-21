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
in
{
  options.dotfiles.ai.haskell = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Haskell language support for Claude Code and Copilot CLI: haskell-language-server as the LSP server for .hs files, and lsmcp (wrapping the same server) as the MCP server. Installs Node.js when enabled.";
    };
  };

  config = lib.mkIf (cfg.enable && cfg.haskell.enable) {
    programs.claude-code = {
      lspServers.haskell = {
        command = hls;
        args = [ "--lsp" ];
        inherit extensionToLanguage;
      };
      mcpServers.haskell = {
        type = "stdio";
        command = "npx";
        args = [
          "-y"
          "@mizchi/lsmcp"
          "-p"
          "hls"
        ];
      };
    };

    programs.github-copilot-cli = {
      lspServers.haskell = {
        command = hls;
        args = [ "--lsp" ];
        fileExtensions = extensionToLanguage;
      };
      mcpServers.haskell = {
        type = "stdio";
        command = "npx";
        args = [
          "-y"
          "@mizchi/lsmcp"
          "-p"
          "hls"
        ];
      };
    };

    home.packages = [
      pkgs.haskellPackages.haskell-language-server
      pkgs.nodejs
    ];
  };
}
