{
  flake.modules.homeManager.kitty = {
    programs.kitty = {
      enable = true;
      enableGitIntegration = true;
      extraConfig = ./kitty.conf; # WIP
    };
  };
}
