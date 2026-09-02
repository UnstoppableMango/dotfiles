{
  lib,
  config,
  pkgs,
  ...
}:
{
  options.dotfiles.rust.enable = lib.mkEnableOption "Rust Toolchain";

  config = lib.mkIf config.dotfiles.rust.enable {
    home.packages = with pkgs; [
      cargo
      rustc
      clippy
      rustfmt
    ];
  };
}
