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
    ./adhd.nix
    ./aws.nix
    ./azure.nix
    ./brave-search.nix
    ./caveman.nix
    ./checkout-root.nix
    ./chrome-devtools.nix
    ./cloudflare.nix
    ./coderabbit.nix
    ./containers.nix
    ./context7.nix
    ./csharp.nix
    ./deepwiki.nix
    ./figma.nix
    ./fsharp.nix
    ./gh-stack.nix
    ./git-mcp.nix
    ./go.nix
    ./gossamer.nix
    ./haskell.nix
    ./kubernetes.nix
    ./moer.nix
    ./nix.nix
    ./notion.nix
    ./ocaml.nix
    ./omnigent.nix
    ./opencode.nix
    ./playwright.nix
    ./remote-control.nix
    ./rust.nix
    ./slack.nix
    ./tdd-orchestrator.nix
    ./terraform.nix
    ./typescript.nix
  ];

  options.dotfiles.ai = {
    enable = lib.mkEnableOption "slop";
  };

  config = lib.mkIf cfg.enable {
    programs.mcp.enable = true;

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
