{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.dotfiles.ai;

  fsautocomplete = lib.getExe pkgs.fsautocomplete;

  extensionToLanguage = {
    ".fs" = "fsharp";
    ".fsi" = "fsharp";
    ".fsx" = "fsharp";
  };

  mcpServer = {
    type = "stdio";
    command = "npx";
    args = [
      "-y"
      "@mizchi/lsmcp"
      "-p"
      "fsharp"
    ];
  };
in
{
  options.dotfiles.ai.fsharp = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "F# language support for Claude Code and Copilot CLI: fsautocomplete (FSAC) as the LSP server for .fs/.fsi/.fsx files, and lsmcp (wrapping the same server) as the MCP server. Installs Node.js when enabled.";
    };
  };

  config = lib.mkIf (cfg.enable && cfg.fsharp.enable) {
    programs.claude-code = {
      lspServers.fsharp = {
        command = fsautocomplete;
        args = [ "--background-service-enabled" ];
        inherit extensionToLanguage;
      };
      mcpServers.fsharp = mcpServer;
    };

    programs.mcp.servers.fsharp = mcpServer;

    programs.github-copilot-cli = {
      lspServers.fsharp = {
        command = fsautocomplete;
        args = [ "--background-service-enabled" ];
        fileExtensions = extensionToLanguage;
      };
      mcpServers.fsharp = mcpServer;
    };

    home.packages = [
      pkgs.fsautocomplete
      pkgs.nodejs
    ];
  };
}
