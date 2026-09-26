{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.dotfiles.dotnet = {
    enable = lib.mkEnableOption "dotnet Toolchain";

    sdks = lib.mkOption {
      type = with lib.types; listOf package;
      default = with pkgs.dotnetCorePackages; [
        sdk_9_0
        sdk_10_0
        dotnet_10.aspnetcore
      ];
      defaultText = lib.literalExpression ''
        with pkgs.dotnetCorePackages; [ sdk_9_0 sdk_10_0 dotnet_10.aspnetcore ]
      '';
      description = "SDKs and runtimes combined into the one `dotnet` on PATH.";
    };
  };

  config = lib.mkIf config.dotfiles.dotnet.enable {
    home.packages = [ (pkgs.dotnetCorePackages.combinePackages config.dotfiles.dotnet.sdks) ];
  };
}
