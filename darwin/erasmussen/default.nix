{
  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.config.allowUnfree = true;

  # Installed with the official multi-user installer, so nix-darwin can own
  # /etc/nix/nix.conf and the daemon. The first switch moves the installer's
  # file aside to nix.conf.before-nix-darwin.
  nix.enable = true;

  nix.settings = {
    experimental-features = [
      "nix-command"
      "flakes"
    ];

    # This account is not in the admin group; sudo is granted in five minute
    # windows. Trusting the user lets `--substituters` / `--extra-substituters`
    # and cachix work from an ordinary shell instead of costing another window.
    trusted-users = [
      "root"
      "erasmussen"
    ];

    substituters = [
      "https://cache.nixos.org"
      "https://unstoppablemango.cachix.org"
    ];
    trusted-public-keys = [
      "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
      "unstoppablemango.cachix.org-1:m7uEI6X1Ov8DyFWJQX4WsRFRWFuzRW5c/Xms8ZaP74U="
    ];
  };

  # nix-darwin does not install Homebrew itself; this only runs `brew bundle`
  # against an existing install. Bootstrap it once with the upstream installer
  # (needs admin) before the first `darwin-rebuild switch`.
  homebrew = {
    enable = true;

    onActivation = {
      autoUpdate = false;
      upgrade = false;
      cleanup = "none"; # switch to "zap" only once casks/brews below are complete and trusted
    };

    # `brew bundle` runs as this account during activation, and /Applications is
    # writable only by the admin group. Casks land in ~/Applications, alongside
    # the bundles Home Manager copies there.
    caskArgs.appdir = "~/Applications";

    taps = [
      "SFDO-Tooling/homebrew-sfdo" # cumulusci is not in homebrew-core
    ];

    brews = [
      "cumulusci" # Salesforce CumulusCI, provides `cci`
    ];

    casks = [
      # nixpkgs' ghostty is Linux-only, so the app comes from Homebrew while
      # Home Manager still writes ~/.config/ghostty/config (modules/terminals).
      "ghostty"
    ];
  };

  system.primaryUser = "erasmussen";
  system.stateVersion = 6;
}
