{
  description = "UnstoppableMango's dotfiles";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    nixos-hardware.url = "github:nixos/nixos-hardware/master";
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixd = {
      url = "github:nix-community/nixd";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
      };
    };
  };

  outputs =
    inputs@{
      self,
      nixpkgs,
      flake-parts,
      treefmt-nix,
      nixos-hardware,
      home-manager,
      nixd,
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      imports = [ treefmt-nix.flakeModule ];
      perSystem =
        { pkgs, ... }:
        {
          treefmt = {
            programs.nixfmt.enable = true;
            programs.nixfmt.package = pkgs.nixfmt-rfc-style;
            programs.dprint.enable = true;
            settings.formatter.dprint.settingsFile = "./.dprint.json";
          };

          devShells.default = pkgs.callPackage ./shell.nix { inherit pkgs; };
        };
      flake = {
        nixosModules = {
          vscode = import ./editors/vscode;
        };

        nixosConfigurations.hades = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          modules = [
            nixos-hardware.nixosModules.asus-rog-strix-x570e
            nixos-hardware.nixosModules.common-pc-ssd
            home-manager.nixosModules.home-manager
            ./hosts/hades/configuration.nix
          ];
        };
      };
    };
}
