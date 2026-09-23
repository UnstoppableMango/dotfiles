{
  inputs,
  self,
  pkgs,
  lib,
  ...
}:
{
  nixpkgs.overlays = [ self.overlays.default ];
  nixpkgs.config.allowUnfree = true;

  # Home Manager asserts `nix.package != null` whenever `nix.settings` is set.
  nix.package = lib.mkDefault pkgs.nix;
  nix.settings = {
    extra-substituters = [ "https://unstoppablemango.cachix.org" ];
    extra-trusted-public-keys = [
      "unstoppablemango.cachix.org-1:m7uEI6X1Ov8DyFWJQX4WsRFRWFuzRW5c/Xms8ZaP74U="
    ];
  };

  dotfiles.ssh.hosts = inputs.hosts.lib.addresses;
}
