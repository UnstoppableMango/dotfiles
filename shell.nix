{
  pkgs ? import <nixpkgs> { },
}:

pkgs.mkShell {
  packages = with pkgs; [
    dprint
    gnumake
    nixfmt-tree
    watchexec
  ];
}
