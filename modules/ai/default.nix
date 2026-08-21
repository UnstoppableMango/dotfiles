{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.dotfiles.ai;

  # Official Anthropic plugin marketplace: https://github.com/anthropics/claude-plugins-official
  claudePluginsOfficial = pkgs.fetchFromGitHub {
    owner = "anthropics";
    repo = "claude-plugins-official";
    rev = "67a666efc8524ff7abaa266f84e514aa77aee48f";
    sha256 = "sha256-PZNjydvhQh2fSbIxRk6+5plJMdD5cYLwZsHNzh3Eowg=";
  };

in
{
  imports = [
    ./azure.nix
    ./caveman.nix
    ./gh-stack.nix
    ./go.nix
    ./nix.nix
    ./ocaml.nix
    ./opencode.nix
    ./rust.nix
    ./typescript.nix
  ];

  options.dotfiles.ai = {
    enable = lib.mkEnableOption "slop";
  };

  config = lib.mkIf cfg.enable {
    programs.claude-code = {
      enable = true;
      context = ./global-context.md;
      plugins = {
        github = "${claudePluginsOfficial}/external_plugins/github";
        claude-md-management = "${claudePluginsOfficial}/plugins/claude-md-management";
      };
      mcpServers = {
        pulumi = {
          type = "http";
          url = "https://mcp.ai.pulumi.com/mcp";
        };
        gitlab = {
          type = "http";
          url = "https://gitlab.com/api/v4/mcp";
        };
      };
    };

    programs.github-copilot-cli = {
      enable = true;
      context = ./global-context.md;
      mcpServers = {
        github = {
          type = "http";
          url = "https://api.githubcopilot.com/mcp/";
          headers.Authorization = "Bearer \${GITHUB_PERSONAL_ACCESS_TOKEN}";
        };
        pulumi = {
          type = "http";
          url = "https://mcp.ai.pulumi.com/mcp";
        };
        gitlab = {
          type = "http";
          url = "https://gitlab.com/api/v4/mcp";
        };
      };
    };

    home.packages = with pkgs; [ cursor-cli ];
  };
}
