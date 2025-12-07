{ self, ... }:
{
  imports = [ ./profiles/hades ];

  flake.modules.homeManager.vscode = {
    imports = [ self.modules.homeManager.vscode-hades ];

    # https://nix-community.github.io/home-manager/options.xhtml#opt-programs.vscode.enable
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
