{ ... }:
{
  config.programs.nixvim = {
    enable = true;
    plugins = {
      claude-code.enable = false;
      direnv.enable = true;

      # https://github.com/MoaidHathot/dotnet.nvim/
      dotnet.enable = false;
      # https://github.com/GustavEikaas/easy-dotnet.nvim/
      easy-dotnet.enable = false;

      haskell-scope-highlighting.enable = false;
      haskell-tools.enable = false;
      helm.enable = false;

      lsp = {
        enable = true;
        servers = {
          angularls.enable = true;
          bashls.enable = true;
          bicep.enable = true;
          buf_ls.enable = true;
          clangd.enable = true;
          cmake.enable = true;
          copilot.enable = true;
          csharp_ls.enable = false;
          css_variables.enable = true;
          dhall_lsp_server.enable = true;
          docker_compose_language_service.enable = true;
          docker_language_server.enable = true;
          dprint.enable = true;
          elixirls.enable = true;
          eslint.enable = true;
          fsautocomplete.enable = true;
          gh_actions_ls.enable = true;
          gopls.enable = true;
          graphql.enable = true;
          helm.enable = true;
          hls.enable = true;
          java_language_server.enable = true;
          jqls.enable = true;
          jsonls.enable = true;
          just.enable = true;
          lua_ls.enable = true;
          nginx_language_server.enable = true;
          nil.enable = true;
          nixd.enable = false;
          ocamllsp.enable = true;
          omnisharp.enable = false;
          postgres_lsp.enable = true;
          rls.enable = false;
          roslyn_ls.enable = true;
          ruby_lsp.enable = true;
          rust_analyzer.enable = true;
          sqls.enable = true;
          svelte.enable = true;
          systemd_ls.enable = true;
          tailwindcss.enable = true;
          terraformls.enable = false;
          tofu_ls.enable = true;
          ts_ls.enable = false;
          tsgo.enable = true;
          typst_lsp.enable = true;
          vimls.enable = true;
          yamlls.enable = true;
          zls.enable = true;
        };
      };
    };
  };
}
