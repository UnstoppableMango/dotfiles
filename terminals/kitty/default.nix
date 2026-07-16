{ lib, config, ... }:
{
  options.dotfiles.kitty.enable = lib.mkEnableOption "kitty";

  config = lib.mkIf config.dotfiles.kitty.enable {
    programs.kitty = {
      enable = true;
      enableGitIntegration = true;

      font = {
        name = "MesloLGS NF Regular";
        size = 12.0;
      };

      shellIntegration.mode = "no-cursor";

      settings = {
        bold_font = "MesloLGS NF Bold";
        italic_font = "MesloLGS NF Italic";
        bold_italic_font = "MesloLGS NF Bold Italic";
        cursor = "none";
        cursor_shape = "block";
        enabled_layouts = "tall:bias=50;full_size=2;mirrored=false";
        background = "#171A1B";
        background_opacity = 0.95;
        allow_hyperlinks = true;
      };
    };
  };
}
