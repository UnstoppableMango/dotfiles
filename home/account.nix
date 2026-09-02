{ ... }:
let
  username = "erik";
in
{
  # Who the account is. Identity, so it lives here rather than in a profile:
  # a profile describes a class of machine, and the person logged into it is
  # not a property of the class. `hosts/server.nix` imports this file directly
  # because it takes the account without the rest of the personal layer.
  home = {
    inherit username;
    homeDirectory = "/home/${username}";

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
