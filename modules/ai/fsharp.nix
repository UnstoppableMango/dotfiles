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
      description = "F# language support for Claude Code and Copilot CLI: fsautocomplete (FSAC) as the LSP server for .fs/.fsi/.fsx files. Installs Node.js when enabled.";
    };

    mcp.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Register lsmcp (wrapping fsautocomplete) as an MCP server. Every configured MCP server starts with each Claude Code and Copilot CLI session regardless of the project's language, so an F# project declares this one in a repo-local .mcp.json instead.";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf (cfg.enable && cfg.fsharp.enable) {
      programs.claude-code.lspServers.fsharp = {
        command = fsautocomplete;
        args = [ "--background-service-enabled" ];
        inherit extensionToLanguage;
      };

      programs.github-copilot-cli.lspServers.fsharp = {
        command = fsautocomplete;
        args = [ "--background-service-enabled" ];
        fileExtensions = extensionToLanguage;
      };

      home.packages = [
        pkgs.fsautocomplete
        pkgs.nodejs
      ];
    })

    (lib.mkIf (cfg.enable && cfg.fsharp.enable && cfg.fsharp.mcp.enable) {
      programs.claude-code.mcpServers.fsharp = mcpServer;
      programs.mcp.servers.fsharp = mcpServer;
      programs.github-copilot-cli.mcpServers.fsharp = mcpServer;
    })
  ];
}
