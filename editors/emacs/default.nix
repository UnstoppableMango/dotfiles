{
  flake.modules.homeManager.emacs = {
    programs.emacs = {
      enable = true;
      extraPackages = epkgs: [
        epkgs.nix-mode
      ];
    };
  };
}
