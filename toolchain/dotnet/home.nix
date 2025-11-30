{ pkgs, lib, ... }:
{
  home.packages = lib.lists.singleton (
    with pkgs.dotnetCorePackages;
    combinePackages [
      sdk_9_0
      sdk_10_0
      dotnet_10.aspnetcore
    ]
  );
}
