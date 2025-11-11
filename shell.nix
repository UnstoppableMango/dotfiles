{
  pkgs ? import <nixpkgs> { },
}:

pkgs.mkShellNoCC {
  packages = with pkgs; [
    dprint
    gnumake
    nixd
    treefmt
    nixfmt-rfc-style
    shellcheck
    watchexec
    ldns
  ];

  DPRINT = pkgs.dprint + "/bin/dprint";
  WATCHEXEC = pkgs.watchexec + "/bin/watchexec";
}
