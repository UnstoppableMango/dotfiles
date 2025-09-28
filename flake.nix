{
  description = "UnstoppableMango's dotfiles";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    nixos-hardware.url = "github:nixos/nixos-hardware/master";
    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      nixos-hardware,
      home-manager,
      ...
    }:
    {
      formatter.x86_64-linux = nixpkgs.legacyPackages.x86_64-linux.nixfmt-tree;

      nixosModules = import ./modules;

      nixosConfigurations.hades = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [
          nixos-hardware.nixosModules.asus-rog-strix-x570e
          nixos-hardware.nixosModules.common-gpu-nvidia
          ./hosts/hades/configuration.nix
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = false;
            home-manger.users.erik = "github:unstoppablemango/dotfiles/nix";

            # Optionally, use home-manager.extraSpecialArgs to pass
            # arguments to home.nix
          }
        ];
      };
    };
}
