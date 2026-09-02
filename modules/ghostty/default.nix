{
  lib,
  pkgs,
  config,
  ...
}:
let
  inherit (pkgs.stdenv.hostPlatform) isDarwin;
in
{
  options.dotfiles.ghostty.enable = lib.mkEnableOption "ghostty";

  config = lib.mkIf config.dotfiles.ghostty.enable {
    programs.ghostty = {
      enable = true;

      # nixpkgs' ghostty is marked linux-only, so on darwin the app comes from
      # elsewhere (Homebrew) and Home Manager owns the config file alone. Shell
      # integration keys off $GHOSTTY_RESOURCES_DIR, which the app exports at
      # runtime, so it keeps working without the package.
      package = lib.mkIf isDarwin null;

      settings = {
        # mkForce: stylix's ghostty target (see modules/stylix) also sets
        # font-family at normal priority, which conflicts outright.
        font-family = lib.mkForce config.dotfiles.zsh.font;
      };
    };
  };
}
