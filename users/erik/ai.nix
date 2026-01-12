{ config, lib, ... }:
let
  module =
    { pkgs, ... }:
    {
      nixpkgs.config.allowUnfree = true;

      programs.claude-code.enable = true;
      home.packages = with pkgs; [
        github-copilot-cli
        cursor-cli
      ];
    };
in
{
  options.ai.enable = lib.mkEnableOption "Slop";
  config.flake.modules.homeManager.ai = lib.mkIf config.ai.enable module;
}
