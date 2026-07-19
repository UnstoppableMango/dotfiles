{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.dotfiles.dotnet.enable = lib.mkEnableOption "dotnet Toolchain";

  config = lib.mkIf config.dotfiles.dotnet.enable {
    home.packages = lib.lists.singleton (
      with pkgs.dotnetCorePackages;
      combinePackages [
        sdk_9_0
        sdk_10_0
        # dotnet_10.aspnetcore # Something about vmr being broken?
      ]
    );
  };
}
