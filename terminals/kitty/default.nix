{
  flake.modules.homeManager.kitty = {
    programs.kitty = {
      enable = true;
      enableGitIntegration = true;
      extraConfig = import ./kitty.conf; # WIP
    };
  };
}
