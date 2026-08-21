{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.dotfiles.ai;
  json = pkgs.formats.json { };

  # https://github.com/JuliusBrussee/caveman
  caveman = pkgs.fetchFromGitHub {
    owner = "JuliusBrussee";
    repo = "caveman";
    rev = "2f49f0e1a352aa810e70056b7930aeb0b3d219b4";
    sha256 = "sha256-FagkzOnjW9tqeaAK8NX1X8REsjWRRMqfrvhByEtrAXM=";
  };
in
{
  options.dotfiles.ai.caveman = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Ultra-compressed communication plugin for Claude Code. Requires Node.js, which is installed automatically when enabled.";
    };
  };

  config = lib.mkIf (cfg.enable && cfg.caveman.enable) {
    programs.claude-code.plugins = { inherit caveman; };

    home.packages = [ pkgs.nodejs ];

    xdg.configFile."caveman/config.json".source = json.generate "caveman-config.json" {
      defaultMode = "off";
    };
  };
}
