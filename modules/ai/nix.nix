{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.dotfiles.ai;

  nixd = lib.getExe pkgs.nixd;
  mcpNixos = lib.getExe pkgs.mcp-nixos;

  mcpServer = {
    type = "stdio";
    command = mcpNixos;
  };
in
{
  options.dotfiles.ai.nix = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Nix language support for Claude Code and Copilot CLI: the nixd LSP server for .nix files, and the mcp-nixos MCP server for live nixpkgs/NixOS/Home Manager/nix-darwin option lookups.";
    };
  };

  config = lib.mkIf (cfg.enable && cfg.nix.enable) {
    programs.claude-code = {
      lspServers.nix = {
        command = nixd;
        extensionToLanguage = {
          ".nix" = "nix";
        };
      };
      mcpServers.nix = mcpServer;
      skills.nix = ./nix-skill;
    };

    programs.mcp.servers.nix = mcpServer;

    programs.github-copilot-cli = {
      lspServers.nix = {
        command = nixd;
        fileExtensions = {
          ".nix" = "nix";
        };
      };
      mcpServers.nix = mcpServer;
      skills.nix = ./nix-skill;
    };

    home.packages = [
      pkgs.nixd
      pkgs.mcp-nixos
    ];
  };
}
