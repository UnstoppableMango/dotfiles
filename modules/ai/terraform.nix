{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.dotfiles.ai;

  # OpenTofu's LSP, not HashiCorp's terraform-ls, to match the tofu_ls
  # preference already set in modules/editors/neovim.
  tofuLs = lib.getExe pkgs.tofu-ls;
  terraformMcp = lib.getExe pkgs.terraform-mcp-server;

  extensionToLanguage = {
    ".tf" = "terraform";
    ".tfvars" = "terraform-vars";
  };

  mcpServer = {
    type = "stdio";
    command = terraformMcp;
    args = [ "stdio" ];
  };
in
{
  options.dotfiles.ai.terraform = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Terraform/OpenTofu support for Claude Code and Copilot CLI: tofu-ls as the LSP server for .tf/.tfvars files, and HashiCorp's official terraform-mcp-server (registry/module docs, HCP Terraform workspace ops) as the MCP server. TFE_TOKEN is optional, only needed for private-registry and workspace features.";
    };
  };

  config = lib.mkIf (cfg.enable && cfg.terraform.enable) {
    programs.claude-code = {
      lspServers.terraform = {
        command = tofuLs;
        args = [ "serve" ];
        inherit extensionToLanguage;
      };
      mcpServers.terraform = mcpServer;
    };

    programs.mcp.servers.terraform = mcpServer;

    programs.github-copilot-cli = {
      lspServers.terraform = {
        command = tofuLs;
        args = [ "serve" ];
        fileExtensions = extensionToLanguage;
      };
      mcpServers.terraform = mcpServer;
    };

    home.packages = [
      pkgs.tofu-ls
      pkgs.terraform-mcp-server
    ];
  };
}
