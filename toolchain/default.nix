{ config, ... }:
{
  imports = [
    ./c
    ./dotnet
    ./git
    ./go
    ./k8s
    ./nix
    ./ocaml
  ];

  flake.modules.homeManager.toolchain = {
    imports = with config.flake.modules.homeManager; [
      c
      dotnet
      git
      go
      k8s
      nix
      ocaml
    ];
  };
}
