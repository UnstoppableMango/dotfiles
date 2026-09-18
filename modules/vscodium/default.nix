{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.dotfiles.vscodium.enable = lib.mkEnableOption "VSCodium";

  config = lib.mkIf config.dotfiles.vscodium.enable {
    # https://nix-community.github.io/home-manager/options.xhtml#opt-programs.vscodium.enable
    programs.vscodium = {
      enable = true;

      # No `haskell` option here: Home Manager imports its haskell submodule
      # for `programs.vscode` alone.
      profiles.default = {
        enableExtensionUpdateCheck = false;
        enableUpdateCheck = false;

        # From the gossamer package's editorSupport passthru. VSCodium reaches
        # Open VSX rather than the marketplace, so nix is the only route here.
        extensions = [ pkgs.gossamer.passthru.editorSupport.vscode ];
      };
    };
  };
}
