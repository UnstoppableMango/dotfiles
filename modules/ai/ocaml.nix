{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.dotfiles.ai;

  ocamllsp = lib.getExe pkgs.ocamlPackages.ocaml-lsp;
in
{
  options.dotfiles.ai.ocaml = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "OCaml language support for Claude Code and Copilot CLI: ocaml-lsp-server as the LSP server for .ml/.mli files.";
    };
  };

  config = lib.mkIf (cfg.enable && cfg.ocaml.enable) {
    programs.claude-code.lspServers.ocaml = {
      command = ocamllsp;
      extensionToLanguage = {
        ".ml" = "ocaml";
        ".mli" = "ocaml";
      };
    };

    programs.github-copilot-cli.lspServers.ocaml = {
      command = ocamllsp;
      fileExtensions = {
        ".ml" = "ocaml";
        ".mli" = "ocaml";
      };
    };

    home.packages = [ pkgs.ocamlPackages.ocaml-lsp ];
  };
}
