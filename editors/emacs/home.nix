{
  programs.emacs = {
    enable = true;
    extraPackages = epkgs: [
      epkgs.nix-mode
    ];
  };
}
