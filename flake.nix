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
    ux = {
      url = "github:unstoppablemango/ux";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };
  };

  outputs =
    inputs@{
      nixpkgs,
      flake-parts,
      treefmt-nix,
      home-manager,
      ...
    }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      flake = {
        homeModules = {
          dconf = ./desktops/gnome/dconf/home.nix;
          erik = ./users/erik/home.nix;
          vscode = ./editors/vscode/home.nix;
          zsh = ./shells/zsh/home.nix;
        };
        homeConfigurations."erik" = home-manager.lib.homeConfiguration {
          pkgs = nixpkgs;
          modules = [ ./users/erik/home.nix ];
        };
      };
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
    };
}
