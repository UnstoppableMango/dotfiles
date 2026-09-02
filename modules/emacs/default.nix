{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.dotfiles.emacs.enable = lib.mkEnableOption "emacs";

  config = lib.mkIf config.dotfiles.emacs.enable {
    programs.emacs = {
      enable = true;
      extraPackages = epkgs: [
        epkgs.nix-mode
        pkgs.gossamer.passthru.editorSupport.emacs
      ];

      # gossamer-mode registers itself with eglot's `eglot-server-programs`
      # on load, but doesn't auto-start eglot per-buffer.
      extraConfig = ''
        (require 'gossamer-mode)
        (add-hook 'gossamer-mode-hook #'eglot-ensure)
      '';
    };
  };
}
