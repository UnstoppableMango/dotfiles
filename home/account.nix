{ config, lib, ... }:
{
  # Account mechanics, no identity: `homeDirectory` derives from whatever
  # `home.username` ends up being, so this composes under any account.
  # `home/default.nix` supplies the "erik" default; `hosts/server.nix` sets
  # its own directly since it imports this file without the rest of `home/`.
  home = {
    homeDirectory = lib.mkDefault "/home/${config.home.username}";

    sessionVariables.DO_NOT_TRACK = "1";

    # This value determines the Home Manager release that your configuration is
    # compatible with. This helps avoid breakage when a new Home Manager release
    # introduces backwards incompatible changes.
    #
    # You should not change this value, even if you update Home Manager. If you
    # do want to update the value, then make sure to first check the Home
    # Manager release notes.
    stateVersion = "25.05"; # Please read the comment before changing.
  };
}
