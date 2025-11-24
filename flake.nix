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
    nixd.url = "github:nix-community/nixd";
    nixvim.url = "github:nix-community/nixvim";
  };

  outputs =
    inputs@{
      nixpkgs,
      flake-parts,
      treefmt-nix,
      nixos-hardware,
      home-manager,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "x86_64-darwin"
        "aarch64-darwin"
      ];
      imports = [
        treefmt-nix.flakeModule
        home-manager.flakeModules.home-manager
      ];
      perSystem =
        { pkgs, ... }:
        {
          devShells.default = pkgs.callPackage ./shell.nix { };

          treefmt = {
            programs.nixfmt.enable = true;
            programs.nixfmt.package = pkgs.nixfmt-rfc-style;

            programs.dprint = {
              enable = false; # Causing issues with flake checks
              settings.plugins = (
                pkgs.dprint-plugins.getPluginList (
                  plugins: with plugins; [
                    dprint-plugin-json
                    dprint-plugin-markdown
                    g-plane-markup_fmt
                    g-plane-pretty_yaml
                  ]
                )
              );
            };
          };
        };
      flake = {
        homeModules = {
          erik = import ./users/erik/home.nix;
        };
        homeConfigurations."erik" = home-manager.lib.homeConfiguration {
          pkgs = nixpkgs;
          modules = [ ./users/erik/home.nix ];
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
