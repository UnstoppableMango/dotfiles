# https://nix-community.github.io/home-manager/options.xhtml#opt-programs.vscode.enable
{ ... }:
{
  imports = [ ./profiles/hades.nix ];
  config = {
    programs.vscode = {
      enable = true;
      haskell = {
        enable = true;

        # TODO: https://nix-community.github.io/home-manager/options.xhtml#opt-programs.vscode.haskell.hie.executablePath
        hie.enable = false;
      };

      profiles.default = {
        enableExtensionUpdateCheck = false;
        enableUpdateCheck = false;
      };
    };
  };
}
