{ inputs, self, ... }:
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

  dotfiles.ssh.hosts = inputs.hosts.lib.addresses;
}
