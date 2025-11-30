{ ... }:
{
  programs.nixvim = {
    enable = true;
    defaultEditor = true;

    opts.number = true;

    editorconfig.enable = true;
    withNodeJs = true;
    withPython3 = true;

    colorscheme = "github_dark";
    colorschemes.github-theme.enable = true;
    colorschemes.vscode.enable = false;

    inherit (import ./module.nix) plugins;
  };
}
