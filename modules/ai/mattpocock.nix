{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.dotfiles.ai;

  # https://github.com/mattpocock/skills
  defaultSrc = pkgs.fetchFromGitHub {
    owner = "mattpocock";
    repo = "skills";
    rev = "49dd158d1076134a641b33efb035946536778336";
    sha256 = "sha256-NljCSZNI3sZ+vbCw7pRdrwR7try4BxOFp4gdjuWYtzs=";
  };

  # The promoted set, as `./skills/<bucket>/<name>` paths.
  pluginManifest = lib.importJSON "${cfg.mattpocock.src}/.claude-plugin/plugin.json";
in
{
  options.dotfiles.ai.mattpocock = {
    enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Matt Pocock's engineering skills (grilling, spec and ticket flows, TDD, code review, domain modeling): the mattpocock-skills plugin for Claude Code, and the same skills mirrored for Copilot CLI.";
    };

    src = lib.mkOption {
      type = lib.types.path;
      default = defaultSrc;
      defaultText = lib.literalExpression "pkgs.fetchFromGitHub { owner = \"mattpocock\"; repo = \"skills\"; ... }";
      description = "Checkout of https://github.com/mattpocock/skills. Copilot CLI's skill list is read from its .claude-plugin/plugin.json, which is import-from-derivation when this is the default fetch rather than a flake input.";
    };
  };

  config = lib.mkIf (cfg.enable && cfg.mattpocock.enable) {
    programs.claude-code.plugins.mattpocock-skills = cfg.mattpocock.src;

    programs.github-copilot-cli.skills = lib.listToAttrs (
      map (
        path: lib.nameValuePair (baseNameOf path) "${cfg.mattpocock.src}/${lib.removePrefix "./" path}"
      ) pluginManifest.skills
    );
  };
}
