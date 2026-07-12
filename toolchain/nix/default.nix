{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.dotfiles.nix.enable = lib.mkEnableOption "nix Toolchain";

  config = lib.mkIf config.dotfiles.nix.enable {
    home.packages = with pkgs; [
      nil
      nixd
      nix-init
      nurl
    ];
  };
}
