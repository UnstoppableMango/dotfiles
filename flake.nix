{
  description = "UnstoppableMango's dotfiles";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs?ref=nixos-unstable";
    flake-parts.url = "github:hercules-ci/flake-parts";
    systems.url = "github:nix-systems/default";

    flake-utils = {
      url = "github:numtide/flake-utils";
      inputs.systems.follows = "systems";
    };

    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixd.url = "github:nix-community/nixd";

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    bun2nix = {
      url = "github:nix-community/bun2nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
      inputs.systems.follows = "systems";
      inputs.treefmt-nix.follows = "treefmt-nix";
    };

    gomod2nix = {
      url = "github:nix-community/gomod2nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    ux = {
      url = "github:unstoppablemango/ux";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
    };

    # https://wiki.nixos.org/wiki/Zed
    # https://github.com/zed-industries/zed/blob/main/flake.nix
    zed = {
      url = "github:zed-industries/zed";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs@{ flake-parts, self, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import inputs.systems;

      imports = [
        inputs.flake-parts.flakeModules.modules
        inputs.treefmt-nix.flakeModule
        inputs.home-manager.flakeModules.home-manager
        inputs.nixvim.flakeModules.default

        ./browsers
        ./desktops
        ./editors
        ./shells
        ./terminals
        ./users
      ];

      flake.modules.flake = {
        ai = ./toolchain/ai;
        brave = ./browsers/brave;
        browsers = ./browsers;
        c = ./toolchain/c;
        claude = ./toolchain/ai/claude;
        copilot = ./toolchain/ai/copilot;
        cursor = ./toolchain/ai/cursor;
        dotnet = ./toolchain/dotnet;
        editors = ./editors;
        emacs = ./editors/emacs;
        erik = ./users/erik;
        ghostty = ./terminals/ghostty;
        git = ./toolchain/git;
        gnome = ./desktops/gnome;
        go = ./toolchain/go;
        helix = ./editors/helix;
        kitty = ./terminals/kitty;
        k8s = ./toolchain/k8s;
        nix = ./toolchain/nix;
        ocaml = ./toolchain/ocaml;
        pgp = ./toolchain/pgp;
        terminals = ./terminals;
        toolchain = ./toolchain;
        vscode = ./editors/vscode;
        zed = ./editors/zed;
        zsh = ./shells/zsh;
      };

      nixvim = {
        packages.enable = true;
        checks.enable = true;
      };

      perSystem =
        { pkgs, system, ... }:
        {
          _module.args.pkgs = import inputs.nixpkgs {
            inherit system;
            overlays = [
              inputs.bun2nix.overlays.default
              inputs.gomod2nix.overlays.default
              inputs.nix-vscode-extensions.overlays.default
            ];
          };

          # https://github.com/nix-community/home-manager/discussions/7551
          # https://github.com/nix-community/home-manager/issues/3075
          # https://github.com/bobvanderlinden/nixos-config/blob/bdfd8d94def9dc36166ef5725589bf3d7ae2d233/flake.nix#L38-L46
          legacyPackages.homeConfigurations =
            with inputs.home-manager.lib;
            let
              cfg = homeManagerConfiguration {
                inherit pkgs;
                modules = [
                  inputs.nixvim.homeModules.nixvim
                  self.modules.homeManager.erik
                ];
              };
            in
            {
              "erik" = cfg;
              "erasmussen" = cfg;
            };

          devShells.default = pkgs.mkShellNoCC {
            packages = with pkgs; [
              direnv
              dprint
              git
              gnumake
              home-manager
              ldns
              nil
              nixd
              nixfmt-rfc-style
              shellcheck
              watchexec
            ];

            DPRINT = pkgs.dprint + "/bin/dprint";
            GIT = pkgs.git + "/bin/git";
            HOMEMANAGER = pkgs.home-manager + "/bin/home-manager";
            NIXFMT = pkgs.nixfmt-rfc-style + "/bin/nixfmt";
            SHELLCHECK = pkgs.shellcheck + "/bin/shellcheck";
            WATCHEXEC = pkgs.watchexec + "/bin/watchexec";
          };

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
