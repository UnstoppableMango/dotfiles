{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.dotfiles.zed = {
    enable = lib.mkEnableOption "Zed";

    extensions = lib.mkOption {
      type = with lib.types; listOf str;
      default = [
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
      description = ''
        Extensions Zed installs on startup, from
        https://github.com/zed-industries/extensions.

        The list is a default here rather than a literal in an identity layer
        because language support, themes, and icon themes are tooling any
        consumer of this flake would plausibly want. Override it wholesale to
        replace the set, or append with `lib.mkAfter`.
      '';
    };
  };

  config = lib.mkMerge [
    (lib.mkIf config.dotfiles.zed.enable {
      programs.zed-editor = {
        enable = true;
        installRemoteServer = true;

        inherit (config.dotfiles.zed) extensions;

        userSettings = {
          # Run "zed: install dev extension" on ~/.config/zed/dev-extensions/gossamer
          # once, and again after each gossamer package update.
          languages.Gossamer.language_servers = [ "gossamer-lsp" ];
          lsp.gossamer-lsp.binary = {
            path = "${pkgs.gossamer}/bin/gos";
            arguments = [ "lsp" ];
          };
        };

        extraPackages = with pkgs; [
          nil
        ];
      };

      xdg.configFile."zed/dev-extensions/gossamer".source = pkgs.gossamer.passthru.editorSupport.zed;

      # Used only if the system nix.conf trusts this cache or the user.
      # Needs a non-null `nix.package`, which the nix instance owner sets.
      nix.settings = {
        extra-substituters = [ "https://zed.cachix.org" ];
        extra-trusted-public-keys = [
          "zed.cachix.org-1:/pHQ6dpMsAZk2DiP4WCL0p9YDNKWj2Q5FL20bNmw1cU="
        ];
      };
    })

    (lib.mkIf config.dotfiles.zed.enable {
      programs.zed-editor.userSettings = {
        features.copilot = lib.mkDefault true;
        telemetry.metrics = lib.mkDefault false;
      };
    })
  ];
}
