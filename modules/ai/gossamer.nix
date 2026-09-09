{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.dotfiles.ai;

  gos = lib.getExe pkgs.gossamer;

  extensionToLanguage = {
    ".gos" = "gossamer";
  };

  # `gos skill-prompt` prints the same content as the upstream SKILL.md, but
  # neither ships YAML frontmatter, so it's added here for skill discovery.
  gossamerSkill = pkgs.runCommand "gossamer-skill" { } ''
    mkdir -p $out
    {
      echo '---'
      echo 'name: gossamer'
      echo 'description: Teaches idiomatic Gossamer (.gos files), covering syntax, the gos toolchain (build/run/test/fmt), and stdlib conventions. Use when writing, reviewing, or debugging Gossamer code, or when the user mentions Gossamer, .gos files, or the gos toolchain.'
      echo '---'
      echo
      ${gos} skill-prompt
    } > $out/SKILL.md
  '';

  mcpServer = {
    type = "stdio";
    command = gos;
    args = [ "mcp" ];
  };
in
{
  options.dotfiles.ai.gossamer = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Gossamer language support for Claude Code and Copilot CLI: gos lsp as the LSP server, and the skill-prompt content as a skill.";
    };

    mcp.enable = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Register gos mcp as an MCP server. Every configured MCP server starts with each Claude Code and Copilot CLI session regardless of the project's language, so a Gossamer project declares this one in a repo-local .mcp.json instead.";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf (cfg.enable && cfg.gossamer.enable) {
      programs.claude-code = {
        lspServers.gossamer = {
          command = gos;
          args = [ "lsp" ];
          inherit extensionToLanguage;
        };
        skills.gossamer = gossamerSkill;
      };

      programs.github-copilot-cli = {
        lspServers.gossamer = {
          command = gos;
          args = [ "lsp" ];
          fileExtensions = extensionToLanguage;
        };
        skills.gossamer = gossamerSkill;
      };

      home.packages = [ pkgs.gossamer ];
    })

    (lib.mkIf (cfg.enable && cfg.gossamer.enable && cfg.gossamer.mcp.enable) {
      programs.claude-code.mcpServers.gossamer = mcpServer;
      programs.mcp.servers.gossamer = mcpServer;
      programs.github-copilot-cli.mcpServers.gossamer = mcpServer;
    })
  ];
}
