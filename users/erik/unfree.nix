let
  username = "erik";
in
{
  # https://github.com/nix-community/home-manager/issues/2954
  flake.modules.homeManager.${username} =
    { pkgs, ... }:
    {
      nixpkgs.config.allowUnfree = true;

      home.packages = with pkgs; [
        cursor-cli
        github-copilot-cli
      ];

      programs.claude-code.enable = true;
    };
}
