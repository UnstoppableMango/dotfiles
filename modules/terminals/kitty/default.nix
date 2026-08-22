{ lib, config, ... }:
{
  options.dotfiles.kitty.enable = lib.mkEnableOption "kitty";

  config = lib.mkIf config.dotfiles.kitty.enable {
    programs.kitty = {
      enable = true;
      enableGitIntegration = true;

      font = {
        # mkForce: stylix's kitty target (see modules/stylix) also sets
        # font.name at normal priority, which conflicts outright.
        name = lib.mkForce "${config.dotfiles.zsh.font} Regular";
        size = lib.mkForce 12.0;
      };

      shellIntegration.mode = "no-cursor";

      settings = {
        bold_font = "${config.dotfiles.zsh.font} Bold";
        italic_font = "${config.dotfiles.zsh.font} Italic";
        bold_italic_font = "${config.dotfiles.zsh.font} Bold Italic";
        cursor = "none";
        cursor_shape = "block";
        enabled_layouts = "tall:bias=50;full_size=2;mirrored=false";
        # mkForce: stylix's kitty target also sets these color keys.
        background = lib.mkForce "#171A1B";
        background_opacity = lib.mkForce 0.95;
        allow_hyperlinks = true;
      };
    };
  };
}
