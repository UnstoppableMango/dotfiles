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
    ./python
  ];

  flake.modules.homeManager.toolchain = {
    imports = with config.flake.modules.homeManager; [
      c
      containers
      dotnet
      git
      go
      javascript
      k9s
      krew
      kubernetes
      nix
      ocaml
      openshift
      python
    ];
  };
}
