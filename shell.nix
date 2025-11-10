{
  pkgs ? import <nixpkgs> { },
}:

pkgs.mkShellNoCC {
  packages = with pkgs; [
    dprint
    gnumake
    shellcheck
    watchexec
  ];

  DPRINT = pkgs.dprint + "/bin/dprint";
  WATCHEXEC = pkgs.watchexec + "/bin/watchexec";
}
