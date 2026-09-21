{
  inputs,
  self,
  pkgs,
  lib,
  ...
}:
{
  # Paired with each host file in flake.nix; host files do not import it.
  imports = with inputs; [
    stylix.homeModules.stylix
    nixvim.homeModules.nixvim
    sops-nix.homeManagerModules.sops
    direnv-instant.homeModules.direnv-instant
    self.homeModules.dotfiles
  ];

  # Set only here: the owner of the nixpkgs instance sets `nixpkgs.*`.
  nixpkgs.overlays = [ self.overlays.default ];
  nixpkgs.config.allowUnfree = true;

  # Silently unused unless the system nix.conf trusts this cache
  # (`trusted-substituters` plus `trusted-public-keys`) or the user.
  #
  # `nix.settings` requires a non-null `nix.package`. Named only here, since a
  # second definition conflicts rather than merges.
  nix.package = lib.mkDefault pkgs.nix;
  nix.settings = {
    extra-substituters = [ "https://unstoppablemango.cachix.org" ];
    extra-trusted-public-keys = [
      "unstoppablemango.cachix.org-1:m7uEI6X1Ov8DyFWJQX4WsRFRWFuzRW5c/Xms8ZaP74U="
    ];
  };

  dotfiles.ssh.hosts = inputs.hosts.lib.addresses;
}
