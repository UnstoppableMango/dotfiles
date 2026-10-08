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

      # gossamer-mode registers with eglot but does not start it per buffer.
      extraConfig = ''
        (require 'gossamer-mode)
        (add-hook 'gossamer-mode-hook #'eglot-ensure)
      '';
    };
  };
}
