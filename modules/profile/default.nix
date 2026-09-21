{ lib, ... }:
{
  # Read by modules/kitty, modules/kubernetes/k9s, modules/zed, and
  # modules/ai/checkout-root.nix; declared together so the taste surface is in one place.
  options.dotfiles.profile = {
    kitty.enable = lib.mkEnableOption "erik's kitty font and color settings";
    k9s.enable = lib.mkEnableOption "erik's k9s pink skin";
    zed.enable = lib.mkEnableOption "erik's Zed editor settings";
    ai.enable = lib.mkEnableOption "erik's ai checkout-root context doc";
  };
}
