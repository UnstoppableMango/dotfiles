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

    nixd = {
      url = "github:nix-community/nixd";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
      inputs.treefmt-nix.follows = "treefmt-nix";
    };

    nil = {
      url = "github:oxalica/nil";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.flake-parts.follows = "flake-parts";
    };

    nix-vscode-extensions = {
      url = "github:nix-community/nix-vscode-extensions";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-direnv = {
      url = "github:nix-community/nix-direnv";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-parts.follows = "flake-parts";
      inputs.treefmt-nix.follows = "treefmt-nix";
    };

    bun2nix = {
      url = "github:nix-community/bun2nix";

      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
        systems.follows = "systems";
        treefmt-nix.follows = "treefmt-nix";
      };
    };

    gomod2nix = {
      url = "github:nix-community/gomod2nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.flake-utils.follows = "flake-utils";
    };

    ux = {
      url = "github:unstoppablemango/ux";

      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
        systems.follows = "systems";
      };
    };

    zed = {
      url = "github:zed-industries/zed?ref=v0.217.3";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mynix = {
      url = "github:UnstoppableMango/nix";

      inputs = {
        nixpkgs.follows = "nixpkgs";
        flake-parts.follows = "flake-parts";
        gomod2nix.follows = "gomod2nix";
        nil.follows = "nil";
        treefmt-nix.follows = "treefmt-nix";
      };
    };
  };

  outputs =
    inputs@{ flake-parts, self, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = import inputs.systems;

      imports = with inputs; [
        flake-parts.flakeModules.modules
        treefmt-nix.flakeModule
        home-manager.flakeModules.home-manager
        nixvim.flakeModules.default

        ./browsers
        ./desktops
        ./editors
        ./shells
        ./terminals
        ./users
      ];

      flake.overlays =
        let
          bun2nix = inputs.bun2nix.overlays.default;
          gomod2nix = inputs.gomod2nix.overlays.default;
          nil = inputs.nil.overlays.default;
          nix-direnv = inputs.nix-direnv.overlays.default;
          vscodeExtensions = inputs.nix-vscode-extensions.overlays.default;
          zed = inputs.zed.overlays.default;

          default = inputs.nixpkgs.lib.composeManyExtensions [
            bun2nix
            gomod2nix
            nil
            nix-direnv
            vscodeExtensions
            zed
          ];
        in
        {
          inherit
            default
            bun2nix
            gomod2nix
            nil
            vscodeExtensions
            zed
            ;
        };

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
        { pkgs, ... }:
        {
          # https://github.com/nix-community/home-manager/discussions/7551
          # https://github.com/nix-community/home-manager/issues/3075
          # https://github.com/bobvanderlinden/nixos-config/blob/bdfd8d94def9dc36166ef5725589bf3d7ae2d233/flake.nix#L38-L46
          legacyPackages.homeConfigurations =
            with inputs.home-manager.lib;
            let
              # Yuck, WIP
              cfg = homeManagerConfiguration {
                inherit pkgs;
                modules = [
                  inputs.nixvim.homeModules.nixvim
                  self.modules.homeManager.erik
                  {
                    nixpkgs.overlays = [
                      self.overlays.default
                    ];
                  }
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
