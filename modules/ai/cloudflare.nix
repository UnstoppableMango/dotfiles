{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.dotfiles.ai;

  # https://github.com/cloudflare/skills
  cloudflareSrc = pkgs.fetchFromGitHub {
    owner = "cloudflare";
    repo = "skills";
    rev = "f96bff754e428838818017f75817f0f9428acd48";
    sha256 = "sha256-r8HeH9XWV9qhbMq3fPASNfT5Y1mrfsgBI5STiUi/LVA=";
  };

  # Mirrors the repo's own .mcp.json, bundled into the Claude plugin below
  # but not something Copilot CLI can pick up automatically.
  mcpServers = {
    cloudflare-api = {
      type = "http";
      url = "https://mcp.cloudflare.com/mcp";
    };
    cloudflare-docs = {
      type = "http";
      url = "https://docs.mcp.cloudflare.com/mcp";
    };
    cloudflare-bindings = {
      type = "http";
      url = "https://bindings.mcp.cloudflare.com/mcp";
    };
    cloudflare-builds = {
      type = "http";
      url = "https://builds.mcp.cloudflare.com/mcp";
    };
    cloudflare-observability = {
      type = "http";
      url = "https://observability.mcp.cloudflare.com/mcp";
    };
  };

  skillNames = [
    "agents-sdk"
    "cloudflare"
    "cloudflare-email-service"
    "cloudflare-one"
    "cloudflare-one-migrations"
    "durable-objects"
    "sandbox-migrate-to-next"
    "sandbox-next"
    "sandbox-stable"
    "turnstile-spin"
    "web-perf"
    "workers-best-practices"
    "wrangler"
  ];
in
{
  options.dotfiles.ai.cloudflare = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Cloudflare developer platform support: the official skills+MCP plugin for Claude Code, and the same MCP servers (Code Mode API, docs, bindings, builds, observability) plus mirrored skills for Copilot CLI.";
    };
  };

  config = lib.mkIf (cfg.enable && cfg.cloudflare.enable) {
    programs.claude-code.plugins.cloudflare = cloudflareSrc;

    programs.github-copilot-cli = {
      inherit mcpServers;
      skills = lib.listToAttrs (
        map (name: lib.nameValuePair name "${cloudflareSrc}/skills/${name}") skillNames
      );
    };
  };
}
