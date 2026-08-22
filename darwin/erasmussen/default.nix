{
  # System-level (nix-darwin) configuration for erasmussen's Mac. Home
  # Manager user config is layered in from flake.nix via
  # home-manager.darwinModules.home-manager + self.homeModules.erasmussen.

  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.config.allowUnfree = true;

  # VERIFY on the actual Mac before first activation: Determinate Nix
  # installer vs the official multi-user installer. If Determinate, keep
  # this false so nix-darwin doesn't fight Determinate's own Nix management.
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
    casks = [
      # fill in erasmussen's actual GUI apps here - none assumed
    ];
  };

  system.primaryUser = "erasmussen";

  # VERIFY: run `scutil --get LocalHostName` on the Mac - this is a guess
  # based on the existing homeConfiguration key
  # ("erasmussen@Eriks-MacBook-Pro.local").
  networking.hostName = "Eriks-MacBook-Pro";

  # VERIFY: check the current recommended value in the nix-darwin manual for
  # whatever revision flake.lock ends up pinning before first activation.
  system.stateVersion = 6; # TODO confirm

  users.users.erasmussen.home = "/Users/erasmussen";
}
