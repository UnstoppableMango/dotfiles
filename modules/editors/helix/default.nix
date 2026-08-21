{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.dotfiles.helix.enable = lib.mkEnableOption "helix";

  config = lib.mkIf config.dotfiles.helix.enable {
    programs.helix.enable = true;

    # Gossamer isn't a built-in Helix language. This mirrors the languages.toml
    # from the gossamer package's editorSupport.helix passthru. The [[grammar]]
    # block is Helix's own fetch+build spec (`hx --grammar fetch/build`); until
    # that's run it falls back to plaintext highlighting, but the language
    # server still attaches.
    programs.helix.languages = {
      language-server.gossamer-lsp = {
        command = "${pkgs.gossamer}/bin/gos";
        args = [ "lsp" ];
      };

      language = [
        {
          name = "gossamer";
          scope = "source.gossamer";
          file-types = [ "gos" ];
          roots = [
            "project.toml"
            ".git"
          ];
          comment-token = "//";
          block-comment-tokens = {
            start = "/*";
            end = "*/";
          };
          indent = {
            tab-width = 4;
            unit = "    ";
          };
          auto-format = false;
          language-servers = [ "gossamer-lsp" ];
        }
      ];

      grammar = [
        {
          name = "gossamer";
          source = {
            git = "https://github.com/gossamer-lang/gossamer-site";
            rev = "main";
            subpath = "editors/tree-sitter-gossamer";
          };
        }
      ];
    };
  };
}
