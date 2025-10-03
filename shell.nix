{
  pkgs ? import <nixpkgs> { },
}:

pkgs.mkShellNoCC {
  packages = with pkgs; [
    dprint
    gnumake
    nixfmt
    nixfmt-tree
    shellcheck
    watchexec
  ];

  WATCHEXEC = pkgs.watchexec + "/bin/watchexec";
}
