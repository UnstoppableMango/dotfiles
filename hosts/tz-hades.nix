{
  # tz's account on hades. The system account comes from the `tz` users
  # instance in the nixos repo, which also installs the Home Manager CLI.
  home = {
    username = "tz";
    homeDirectory = "/home/tz";
    stateVersion = "26.05";
  };

  programs.home-manager.enable = true;
}
