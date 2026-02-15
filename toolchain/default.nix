{ config, ... }:
{
  imports = [
    ./c
    ./containers
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
      containers
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
