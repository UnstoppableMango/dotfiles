{ self, ... }:
{
  flake.modeModules.neovim = self.modules.homeManager.neovim;
  flake.modules.homeManager.neovim = {
    programs.nixvim = {
      enable = true;
      defaultEditor = true;

      opts.number = true;

      editorconfig.enable = true;
      withNodeJs = true;
      withPython3 = true;

      colorschemes.vscode.enable = true;

      diagnostic.settings = {
        open_float = true;
      };

      plugins = {
        bufferline.enable = true;
        web-devicons.enable = true;
        claude-code.enable = false;
        direnv.enable = true;

        # https://github.com/MoaidHathot/dotnet.nvim/
        dotnet.enable = false;
        # https://github.com/GustavEikaas/easy-dotnet.nvim/
        easy-dotnet.enable = false;

        haskell-scope-highlighting.enable = false;
        haskell-tools.enable = false;
        helm.enable = false;
        lspconfig.enable = true;
      };

      lsp = {
        inlayHints.enable = true;
        servers = {
          bashls.enable = true;
          bicep.enable = true;
          buf_ls.enable = true;
          clangd.enable = true;
          cmake.enable = true;
          copilot.enable = false; # TODO: Unfree
          dhall_lsp_server.enable = true;
          dprint.enable = true;
          elixirls.enable = true;
          fsautocomplete.enable = true;
          gh_actions_ls.enable = true;
          graphql.enable = true;
          helm_ls.enable = true;
          java_language_server.enable = true;
          jqls.enable = true;
          jsonls.enable = true;
          just.enable = true;
          lua_ls.enable = true;
          nginx_language_server.enable = true;
          ocamllsp.enable = true;
          ruby_lsp.enable = true;
          systemd_ls.enable = true;
          vimls.enable = true;
          yamlls.enable = true;
          zls.enable = true;

          # Typst
          tinymist.enable = false;
          typst_lsp.enable = true;

          # Web
          html.enable = true;
          htmx.enable = true;
          css_variables.enable = true;
          tailwindcss.enable = true;
          angularls.enable = true;
          svelte.enable = true;
          eslint.enable = true;

          # Go
          golangci_lint_ls.enable = true;
          gopls.enable = true;

          # Docker
          docker_compose_language_service.enable = true;
          docker_language_server.enable = true;

          # Terraform
          terraformls.enable = false;
          tofu_ls.enable = true;

          # TypeScript
          ts_ls.enable = false;
          tsgo.enable = true;

          # SQL
          sqls.enable = true;
          postgres_lsp.enable = true;

          # Haskell
          ghcide.enable = false;
          hls.enable = true;

          # Nix
          nil_ls.enable = true;
          nixd.enable = false;

          # .NET
          roslyn_ls.enable = true;
          csharp_ls.enable = false;
          omnisharp.enable = false;

          # Rust
          rls.enable = false;
          rust_analyzer.enable = true;
        };
      };
    };
  };
}
