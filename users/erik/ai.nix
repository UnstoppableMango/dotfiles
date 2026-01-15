{
  config.flake.modules.homeManager.ai =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    {
      options.ai.enable = lib.mkEnableOption "Slop";
      config = lib.mkIf config.ai.enable {
        programs.claude-code.enable = true;
        home.packages = with pkgs; [
          github-copilot-cli
          cursor-cli
        ];
      };
    };
}
