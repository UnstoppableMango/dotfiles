{
  flake.modules.homeManager.copilot =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        github-copilot-cli
      ];
    };
}
