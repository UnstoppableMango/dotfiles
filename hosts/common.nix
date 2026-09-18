{
  inputs,
  self,
  pkgs,
  lib,
  ...
}:
{
  # What every home configuration in this flake is built on. Imported by
  # flake.nix alongside each host file rather than by the host files.
  imports = with inputs; [
    stylix.homeModules.stylix
    nixvim.homeModules.nixvim
    sops-nix.homeManagerModules.sops
    nix2git.homeModules.nix2git
    direnv-instant.homeModules.direnv-instant
    self.homeModules.dotfiles
  ];

  # `nixpkgs.*` belongs to whoever owns the nixpkgs instance. Every
  # configuration here is standalone and so owns its own, which is why these
  # are set once here rather than anywhere under `modules/` or `home/`. A
  # consumer composing `homeModules.dotfiles` into the Home Manager NixOS
  # module with `useGlobalPkgs` keeps that ownership at the system level, and
  # nothing in the tree fights them for it.
  nixpkgs.overlays = [ self.overlays.default ];
  nixpkgs.config.allowUnfree = true;

  # The cache CI pushes every configuration to. Without it the packages that
  # exist only in the `mangopkgs` overlay have no substituter at all, since
  # cache.nixos.org carries nothing that is not in nixpkgs, so each version
  # bump of one is built from source on every machine. Set here rather than
  # beside any one package, because the cache serves the whole flake.
  #
  # A user's nix.conf reaches a substituter only with the system's permission,
  # and silently substitutes nothing without it, so a host that compiles anyway
  # is missing one of two things in its system nix.conf. Either is enough:
  #
  # - the cache URL in `trusted-substituters` and this signing key in
  #   `trusted-public-keys`, which authorizes exactly this cache; or
  # - the user in `trusted-users`, which authorizes any cache they name.
  #
  # Prefer the first. Nix's own manual warns that adding a user to
  # `trusted-users` "is essentially equivalent to giving that user root access
  # to the system", which is a steep price for one binary cache.
  #
  # `nix.package` is null by default and `nix.settings` asserts against that,
  # so nix.conf renders only once something names a package. One definition,
  # here: a package is not a mergeable value, so a second module naming the
  # same one is a conflict rather than a merge, and Home Manager's own null
  # default occupies the rung below. A consumer taking `homeModules.dotfiles`
  # without this file therefore sets `nix.package` itself to use any module
  # that writes `nix.settings`.
  nix.package = lib.mkDefault pkgs.nix;
  nix.settings = {
    extra-substituters = [ "https://unstoppablemango.cachix.org" ];
    extra-trusted-public-keys = [
      "unstoppablemango.cachix.org-1:m7uEI6X1Ov8DyFWJQX4WsRFRWFuzRW5c/Xms8ZaP74U="
    ];
  };

  dotfiles.ssh.hosts = inputs.hosts.lib.addresses;
}
