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

  skillNames = map baseNameOf pluginManifest.skills;

  # Claude Code rejects manifest skill paths that resolve outside the plugin
  # directory, and Home Manager installs a plugin as symlinks into the store.
  # So the promoted skills are flattened to skills/<name> and the manifest's
  # `skills` list is dropped, leaving Claude Code to discover them.
  plugin =
    assert lib.assertMsg (lib.allUnique skillNames)
      "dotfiles.ai.mattpocock: plugin.json lists two skills with the same directory name";
    pkgs.runCommand "mattpocock-skills-plugin" { } ''
      mkdir -p $out/skills $out/.claude-plugin
      ${lib.concatMapStrings (path: ''
        cp -r ${cfg.mattpocock.src}/${lib.removePrefix "./" path} $out/skills/${baseNameOf path}
      '') pluginManifest.skills}
      cp ${
        pkgs.writeText "plugin.json" (builtins.toJSON (removeAttrs pluginManifest [ "skills" ]))
      } $out/.claude-plugin/plugin.json
    '';
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
    programs.claude-code.plugins.mattpocock-skills = plugin;

    programs.github-copilot-cli.skills = lib.genAttrs skillNames (name: "${plugin}/skills/${name}");

    dotfiles.ai.crush.crushrc = "option skill-path ${plugin}/skills";
  };
}
