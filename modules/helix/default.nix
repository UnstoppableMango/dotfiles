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

    # Highlighting stays plaintext until `hx --grammar fetch` and `build` run.
    programs.helix.languages = pkgs.gossamer.passthru.editorSupport.helix.languages;
  };
}
