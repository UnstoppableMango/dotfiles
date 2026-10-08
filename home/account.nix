{ config, lib, ... }:
{
  home = {
    homeDirectory = lib.mkDefault "/home/${config.home.username}";

    sessionVariables.DO_NOT_TRACK = "1";

    # Changing this needs the Home Manager release notes checked first.
    stateVersion = "25.05";
  };
}
