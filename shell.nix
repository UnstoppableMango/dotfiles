{
  pkgs ? import <nixpkgs> { },
}:

pkgs.mkShellNoCC {
  packages = with pkgs; [
    direnv
    dprint
    git
    gnumake
    home-manager
    ldns
    neovim
    nil
    nixd
    nixfmt-rfc-style
    shellcheck
    watchexec
  ];

  DPRINT = pkgs.dprint + "/bin/dprint";
  GIT = pkgs.git + "/bin/git";
  HOMEMANAGER = pkgs.home-manager + "/bin/home-manager";
  NIXFMT = pkgs.nixfmt-rfc-style + "/bin/nixfmt";
  SHELLCHECK = pkgs.shellcheck + "/bin/shellcheck";
  WATCHEXEC = pkgs.watchexec + "/bin/watchexec";
}
