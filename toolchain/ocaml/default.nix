{ lib, config, ... }:
{
  options.dotfiles.ocaml.enable = lib.mkEnableOption "OCaml Toolchain";

  config = lib.mkIf config.dotfiles.ocaml.enable {
    programs.opam = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
