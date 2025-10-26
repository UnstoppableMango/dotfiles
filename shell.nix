{
  pkgs ? import <nixpkgs> { },
}:

pkgs.mkShellNoCC {
  packages = with pkgs; [
    dprint
    gnumake
    nixfmt-rfc-style
    nixfmt-tree
    shellcheck
    watchexec
  ];

  WATCHEXEC = pkgs.watchexec + "/bin/watchexec";
}
