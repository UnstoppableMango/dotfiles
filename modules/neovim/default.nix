{
  lib,
  config,
  ...
}:
let
  cfg = config.dotfiles.neovim;
in
{
  options.dotfiles.neovim = {
    enable = lib.mkEnableOption "neovim";

    defaultConfig = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = ''
        Import the curated nixvim configuration in `./nixvim-config.nix`: the
        LSP server set, plugin list, colorscheme, and the gossamer language
        support wired up from the package's `editorSupport` passthru.

        It is a default here rather than a literal in an identity layer because
        it is a toolchain choice any consumer of this flake would plausibly
        want, not a personal one. Set false to configure `programs.nixvim` from
        scratch; the rest of the module still applies.

        The same file is exported as `nixvimModules.default`, which is what
        `packages.nixvim` builds standalone.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    programs.nixvim = {
      enable = true;
      defaultEditor = true;

      nixpkgs.useGlobalPackages = true;

      imports = lib.optional cfg.defaultConfig ./nixvim-config.nix;
    };
  };
}
