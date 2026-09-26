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
    ./claude-desktop.nix
    ./cloudflare.nix
    ./coderabbit.nix
    ./containers.nix
    ./context7.nix
    ./csharp.nix
    ./cursor.nix
    ./deepwiki.nix
    ./figma.nix
    ./fsharp.nix
    ./gh-stack.nix
    ./github.nix
    ./git-mcp.nix
    ./gitlab.nix
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
    ./pulumi.nix
    ./remote-control.nix
    ./rust.nix
    ./slack.nix
    ./tdd-orchestrator.nix
    ./terraform.nix
    ./typescript.nix
  ];

  options.dotfiles.ai = {
    enable = lib.mkEnableOption "slop";

    copilot.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "GitHub Copilot CLI.";
    };

    cursor.cli.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Cursor CLI.";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.mcp.enable = true;

    programs.claude-code = {
      enable = true;
      context = ./global-context.md;
      plugins = {
        # github.nix supplies the server itself when ghAuth is on.
        github = lib.mkIf (!cfg.github.ghAuth) "${claudePluginsOfficial}/external_plugins/github";
        claude-md-management = "${claudePluginsOfficial}/plugins/claude-md-management";
      };
    };

    programs.github-copilot-cli = {
      enable = cfg.copilot.enable;
      context = ./global-context.md;
    };

    home.packages = lib.optional cfg.cursor.cli.enable pkgs.cursor-cli;
  };
}
