{
  flake.modules.homeManager.zed =
    { pkgs, ... }:
    {
      # https://nix-community.github.io/home-manager/options.xhtml#opt-programs.zed-editor.enable
      programs.zed-editor = {
        enable = true;
        installRemoteServer = true;

        userSettings = {
          features = {
            copilot = true;
          };
          telemetry = {
            metrics = false;
          };
        };

        # https://github.com/zed-industries/extensions/tree/main/extensions
        extensions = [
          "csharp"
          "deno"
          "discord-presence"
          "docker-compose"
          "dockerfile"
          "dprint"
          "editorconfig"
          "elixir"
          "fsharp"
          "ghostty"
          "github-actions"
          "golangci-lint"
          "graphql"
          "haskell"
          "helm"
          "http"
          "jq"
          "json5"
          "lua"
          "make"
          "nix"
          "ocaml"
          "opentofu"
          "postgres-language-server"
          "proto"
          "purescript"
          "ruby"
          "sql"
          "ssh-config"
          "svelte"
          "terraform"
          "tmux"
          "typst"
          "xml"
          "zig"

          # Themes
          "tailwind-theme"
          "vercel-theme"
          "vscode-dark-modern"
          "vscode-dark-polished"
        ];

        extraPackages = with pkgs; [
          nil
        ];
      };
    };
}
