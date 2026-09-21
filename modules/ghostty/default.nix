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

      # nixpkgs' ghostty is linux-only; on darwin the app is installed separately.
      package = lib.mkIf isDarwin null;

      settings = {
        # mkForce: stylix's ghostty target also sets font-family.
        font-family = lib.mkForce config.dotfiles.zsh.font;
      };
    };
  };
}
