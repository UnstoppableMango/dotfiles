{ ... }:
{
  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    editorconfig.enable = true;
    withNodeJs = true;
    withPython3 = true;
    colorschemes.vscode.enable = true;

    inherit (import ./module.nix) plugins;
  };
}
