{ config, ... }:
{
  imports = [
    ./c
    ./dotnet
    ./git
    ./go
    ./javascript
    ./kubernetes
    ./nix
    ./ocaml
  ];

  flake.modules.homeManager.toolchain = {
    imports = with config.flake.modules.homeManager; [
      c
      dotnet
      git
      go
      javascript
      krew
      kubernetes
      nix
      ocaml
      openshift
    ];
  };
}
