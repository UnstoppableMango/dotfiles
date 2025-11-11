{
  pkgs ? import <nixpkgs> { },
}:

pkgs.mkShellNoCC {
  packages = with pkgs; [
    dprint
    gnumake
    nixd
    treefmt
    shellcheck
    watchexec
  ];

  DPRINT = pkgs.dprint + "/bin/dprint";
  WATCHEXEC = pkgs.watchexec + "/bin/watchexec";
}
