{ lib, config, ... }:
{
  options.dotfiles.emacs.enable = lib.mkEnableOption "emacs";

  config = lib.mkIf config.dotfiles.emacs.enable {
    programs.emacs = {
      enable = true;
      extraPackages = pkgs: [
        pkgs.nix-mode
      ];
    };
  };
}
