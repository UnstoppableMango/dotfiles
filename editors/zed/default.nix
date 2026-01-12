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
          "toml"
          "typst"
          "xml"
          "zig"

          # Themes
          "tailwind-theme"
          "vercel-theme"
          "vscode-dark-modern"
          "vscode-dark-polished"

          # Icon Themes
          "catppuccin-icons"
          "material-icon-theme"
          "vscode-icons"
          "colored-zed-icons-theme"
          "jetbrains-new-ui-icons"
          "vscode-great-icons"
          "serendipity"
          "min-theme"
          "symbols"
          "bearded-icon-theme"
          "charmed-icons"
          "jetbrains-icons"
          "phosphor-icons-theme"
          "openmoji-icons"
          "monospace-icon-theme"
          "modern-icons"
          "chawyehsu-vscode-icons"
          "seti-icons"
          "puppet"
          "icons-modern-material"
          "ton"
          "clean-vscode-icons"
          "fantasticons-icons-theme"
        ];

        extraPackages = with pkgs; [
          nil
        ];
      };
    };
}
