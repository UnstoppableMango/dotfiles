{ lib, config, ... }:
{
  options.dotfiles.kitty.enable = lib.mkEnableOption "kitty";

  config = lib.mkIf config.dotfiles.kitty.enable {
    programs.kitty = {
      enable = true;
      enableGitIntegration = true;
      shellIntegration.mode = "no-cursor";

      font = {
        # mkForce: stylix's kitty target also sets the font.
        name = lib.mkForce "${config.dotfiles.zsh.font} Regular";
        size = lib.mkForce 12.0;
      };

      settings =
        lib.mapAttrs (_: lib.mkDefault) {
          bold_font = "${config.dotfiles.zsh.font} Bold";
          italic_font = "${config.dotfiles.zsh.font} Italic";
          bold_italic_font = "${config.dotfiles.zsh.font} Bold Italic";
          cursor = "none";
          cursor_shape = "block";
          enabled_layouts = "tall:bias=50;full_size=2;mirrored=false";
          allow_hyperlinks = true;
        }
        // {
          # mkForce: stylix's kitty target also sets this key.
          background_opacity = lib.mkForce 0.95;
        };
    };
  };
}
