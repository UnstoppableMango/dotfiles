{ pkgs, ... }:
{
  # Highlight queries in gossamer.nvim are inert without nvim-treesitter.
  extraPlugins = [ pkgs.gossamer.passthru.editorSupport.neovim ];

  extraConfigLua = ''
    vim.lsp.enable("gossamer")
  '';
}
