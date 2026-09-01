{
  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.config.allowUnfree = true;

  nix.enable = false; # TODO confirm against actual installer

  # nix-darwin does not install Homebrew itself - it must already be
  # present on this Mac before `homebrew.enable = true` will activate
  # successfully.
  homebrew = {
    enable = true;
    onActivation = {
      autoUpdate = false;
      upgrade = false;
      cleanup = "none"; # switch to "zap" only once casks/brews below are complete and trusted
    };
    taps = [ ];
    brews = [ ];
    casks = [ ];
  };

  system.primaryUser = "erasmussen";
  system.stateVersion = 6; # TODO confirm
}
