{
  pkgs ? import <nixpkgs> { },
}:

pkgs.mkShellNoCC {
  packages = with pkgs; [
    dprint
    gnumake
    ldns
    nixd
    nixfmt-rfc-style
    shellcheck
    watchexec
  ];

  DPRINT = pkgs.dprint + "/bin/dprint";
  NIXFMT = pkgs.nixfmt-rfc-style + "/bin/nixfmt";
  WATCHEXEC = pkgs.watchexec + "/bin/watchexec";
}
