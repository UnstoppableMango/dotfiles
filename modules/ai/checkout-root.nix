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
      default = ./checkout-root.md;
      description = ''
        Markdown describing how the checkout root is organized, rendered to
        `<path>/AGENTS.md` alongside a `CLAUDE.md` pointing at it, the same
        pairing the repos underneath use. Agents started in any repo pick it up
        by walking parent directories, so conventions that span repos live here
        rather than being repeated in each one. Null writes nothing.
      '';
    };
  };

  config = lib.mkIf (cfg.enable && root.context != null) {
    home.file = {
      "${root.path}/AGENTS.md".source = root.context;
      "${root.path}/CLAUDE.md".text = "@AGENTS.md\n";
    };
  };
}
