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
      description = "Gossamer language support for Claude Code and Copilot CLI: gos lsp as the LSP server, gos mcp as the MCP server, and the skill-prompt content as a skill.";
    };
  };

  config = lib.mkIf (cfg.enable && cfg.gossamer.enable) {
    programs.claude-code = {
      lspServers.gossamer = {
        command = gos;
        args = [ "lsp" ];
        inherit extensionToLanguage;
      };
      mcpServers.gossamer = mcpServer;
      skills.gossamer = gossamerSkill;
    };

    programs.mcp.servers.gossamer = mcpServer;

    programs.github-copilot-cli = {
      lspServers.gossamer = {
        command = gos;
        args = [ "lsp" ];
        fileExtensions = extensionToLanguage;
      };
      mcpServers.gossamer = mcpServer;
      skills.gossamer = gossamerSkill;
    };

    home.packages = [ pkgs.gossamer ];
  };
}
