{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.dotfiles.helix.enable = lib.mkEnableOption "helix";

  config = lib.mkIf config.dotfiles.helix.enable {
    programs.helix.enable = true;

    # Gossamer isn't a built-in Helix language. The [[grammar]] block is
    # Helix's own fetch+build spec (`hx --grammar fetch/build`); until that's
    # run it falls back to plaintext highlighting, but the language server
    # still attaches.
    programs.helix.languages = pkgs.gossamer.passthru.editorSupport.helix.languages;
  };
}
