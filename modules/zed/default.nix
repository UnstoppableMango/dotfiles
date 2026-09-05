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
      # https://nix-community.github.io/home-manager/options.xhtml#opt-programs.zed-editor.enable
      programs.zed-editor = {
        enable = true;
        installRemoteServer = true;

        inherit (config.dotfiles.zed) extensions;

        userSettings = {
          # Gossamer isn't a published Zed extension. The extension directory
          # is materialized at ~/.config/zed/dev-extensions/gossamer; run
          # "zed: install dev extension" once, pointing at that path (and
          # again whenever the gossamer package updates, since the target is
          # a nix store path).
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

      # Zed's own binary cache, so a host that runs Zed does not build it.
      # Home Manager only writes the user's nix.conf, and Nix ignores
      # substituters from an untrusted user, so this takes effect only where
      # erik is in the system's `trusted-users`: on NixOS the machine config
      # sets that, elsewhere it is a manual line in /etc/nix/nix.conf.
      #
      # nix.package is null by default and nix.settings asserts against that.
      nix.package = lib.mkDefault pkgs.nix;
      nix.settings = {
        extra-substituters = [ "https://zed.cachix.org" ];
        extra-trusted-public-keys = [
          "zed.cachix.org-1:/pHQ6dpMsAZk2DiP4WCL0p9YDNKWj2Q5FL20bNmw1cU="
        ];
      };
    })

    (lib.mkIf config.dotfiles.profile.zed.enable {
      programs.zed-editor.userSettings = {
        features.copilot = true;
        telemetry.metrics = false;
      };
    })
  ];
}
