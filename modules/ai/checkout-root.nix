{
  lib,
  config,
  ...
}:
let
  cfg = config.dotfiles.ai;
  root = cfg.checkoutRoot;
in
{
  options.dotfiles.ai.checkoutRoot = {
    path = lib.mkOption {
      type = lib.types.str;
      default = "src";
      description = "Directory holding git checkouts, relative to the home directory.";
    };

    context = lib.mkOption {
      type = with lib.types; nullOr path;
      default = null;
      description = ''
        Markdown describing how the checkout root is organized, rendered to
        `<path>/AGENTS.md` alongside a `CLAUDE.md` pointing at it, the same
        pairing the repos underneath use. Agents started in any repo pick it up
        by walking parent directories, so conventions that span repos live here
        rather than being repeated in each one. Null, the default, writes
        nothing, keeping the module free of any assumption that a checkout root
        exists.
      '';
    };
  };

  config = lib.mkMerge [
    (lib.mkIf (cfg.enable && root.context != null) {
      home.file = {
        "${root.path}/AGENTS.md".source = root.context;
        "${root.path}/CLAUDE.md".text = "@AGENTS.md\n";
      };
    })

    (lib.mkIf config.dotfiles.profile.ai.enable {
      dotfiles.ai.checkoutRoot.context = lib.mkDefault ./checkout-root.md;
    })
  ];
}
