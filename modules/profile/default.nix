{ lib, ... }:
{
  # Per-tool sub-toggles for erik's curated "taste": defaults that are a
  # personal choice (a color scheme, a telemetry opt-out, a checkout-root
  # convention doc) rather than a toolchain default any consumer of this
  # flake would want (compare dotfiles.neovim.defaultConfig,
  # dotfiles.zsh.p10kConfig, dotfiles.zed.extensions, which stay
  # unconditional module defaults with no separate toggle).
  #
  # Each toggle is read by its own module (modules/kitty,
  # modules/kubernetes/k9s, modules/zed, modules/ai/checkout-root.nix) to
  # decide whether to layer erik's curated values on top of that module's
  # mechanical defaults. Declared here, in one file, so the whole taste
  # surface is visible in one place rather than scattered across four
  # modules; home/taste.nix flips all four at once for the identity that
  # wants the whole bundle, and a consumer of homeModules.dotfiles can flip
  # exactly one instead.
  options.dotfiles.profile = {
    kitty.enable = lib.mkEnableOption "erik's kitty font and color settings";
    k9s.enable = lib.mkEnableOption "erik's k9s pink skin";
    zed.enable = lib.mkEnableOption "erik's Zed editor settings";
    ai.enable = lib.mkEnableOption "erik's ai checkout-root context doc";
  };
}
