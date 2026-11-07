{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.dotfiles.javascript;
in
{
  options.dotfiles.javascript = {
    enable = lib.mkEnableOption "JavaScript Toolchain";

    corepack.enable = lib.mkEnableOption ''
      corepack's `yarn` and `pnpm` shims, which run whichever version a
      project pins in its `package.json` `packageManager` field. The way to
      get yarn 2 and later, which nixpkgs' `yarn` (1.x) is not'';
  };

  config = lib.mkIf cfg.enable {
    home.packages =
      with pkgs;
      [
        fnm
        zx
      ]
      ++ lib.optional cfg.corepack.enable corepack;

    programs.zsh.initContent = lib.mkIf config.dotfiles.zsh.enable ''
      eval "$(${pkgs.fnm}/bin/fnm env --use-on-cd --shell zsh)"
    '';
  };
}
