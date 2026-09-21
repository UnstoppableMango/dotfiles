{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.dotfiles.vscodium.enable = lib.mkEnableOption "VSCodium";

  config = lib.mkIf config.dotfiles.vscodium.enable {
    programs.vscodium = {
      enable = true;

      # Home Manager's `haskell` submodule exists for `programs.vscode` only.
      profiles.default = {
        enableExtensionUpdateCheck = false;
        enableUpdateCheck = false;

        extensions = [ pkgs.gossamer.passthru.editorSupport.vscode ];
      };
    };
  };
}
