{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.dotfiles.ai;

  # https://github.com/aws/agent-toolkit-for-aws
  awsToolkitSrc = pkgs.fetchFromGitHub {
    owner = "aws";
    repo = "agent-toolkit-for-aws";
    rev = "d6ad2e44d5e3077b85b63f322e007c84f94f3a6c";
    sha256 = "sha256-ZcU3e9VyPEx3e9DZq1LVimsmQobLX9pzcJy3zT2fVts=";
  };
  awsCoreSrc = "${awsToolkitSrc}/plugins/aws-core";

  # aws-core minus its MCP server, keeping the skills and the secret-safety hook.
  awsCoreNoMcp = pkgs.runCommand "aws-core-no-mcp" { } ''
    cp -r ${awsCoreSrc} $out
    chmod -R u+w $out
    rm $out/.mcp.json $out/mcp.json
  '';

  # mcp-proxy-for-aws signs requests with the local AWS credentials, not OAuth.
  mcpServer = {
    type = "stdio";
    command = "uvx";
    args = [
      "mcp-proxy-for-aws@1.6.4"
      "https://aws-mcp.us-east-1.api.aws/mcp"
      "--skip-auth"
      "--metadata"
      "INSTALL_SOURCE=dotfiles"
    ];
  };

  skillNames = [
    "amazon-bedrock"
    "aws-ai-ml"
    "aws-billing-and-cost-management"
    "aws-blocks"
    "aws-cdk"
    "aws-cloudformation"
    "aws-compute"
    "aws-containers"
    "aws-database"
    "aws-deployment"
    "aws-iam"
    "aws-messaging-and-streaming"
    "aws-observability"
    "aws-sdk-js-v3-usage"
    "aws-sdk-python-usage"
    "aws-sdk-swift-usage"
    "aws-secrets-manager"
    "aws-serverless"
    "aws-storage"
    "launch-with-aws"
    "signing-in-to-aws"
  ];
in
{
  options.dotfiles.ai.aws = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "AWS support: the aws-core plugin (skills, the managed AWS MCP Server, and a secret-safety PreToolUse hook) for Claude Code, and the same MCP server plus mirrored skills for Copilot CLI, which has no plugin/hook system. Installs uv and python3 when enabled. Without `mcp.enable`, the plugin ships without its MCP server.";
    };

    mcp.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Register the managed AWS MCP Server. Every configured MCP server starts with each Claude Code and Copilot CLI session, so a project that wants this one declares it in a repo-local .mcp.json instead.";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf (cfg.enable && cfg.aws.enable) {
      programs.claude-code.plugins."aws-core" = if cfg.aws.mcp.enable then awsCoreSrc else awsCoreNoMcp;

      programs.github-copilot-cli.skills = lib.listToAttrs (
        map (name: lib.nameValuePair name "${awsCoreSrc}/skills/${name}") skillNames
      );

      home.packages = [
        pkgs.uv
        pkgs.python3
      ];
    })

    (lib.mkIf (cfg.enable && cfg.aws.enable && cfg.aws.mcp.enable) {
      programs.github-copilot-cli.mcpServers.aws = mcpServer;
      programs.mcp.servers.aws = mcpServer;
    })
  ];
}
