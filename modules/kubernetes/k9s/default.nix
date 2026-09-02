{ lib, config, ... }:
{
  options.dotfiles.k9s.enable = lib.mkOption {
    type = lib.types.bool;
    default = config.dotfiles.kubernetes.enable;
    description = "k9s Kubernetes TUI";
  };

  config = lib.mkIf config.dotfiles.k9s.enable {
    programs.k9s.enable = true;
  };
}
