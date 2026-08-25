{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.dotfiles.vscode.enable = lib.mkEnableOption "VSCode";

  config = lib.mkIf config.dotfiles.vscode.enable {
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

        # Not on the marketplace, from the gossamer package's editorSupport
        # passthru instead.
        extensions = [ pkgs.gossamer.passthru.editorSupport.vscode ];
      };
    };
  };
}
