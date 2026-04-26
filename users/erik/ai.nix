{
  pkgs,
  lib,
  config,
  ...
}:
{
  options.dotfiles.ai.enable = lib.mkEnableOption "Slop";
  config = lib.mkIf config.dotfiles.ai.enable {
    programs.claude-code.enable = true;
    home.packages = with pkgs; [
      github-copilot-cli
      cursor-cli
    ];
  };
}
