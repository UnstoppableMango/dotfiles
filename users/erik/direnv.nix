{
  direnv = {
    enable = true;
    # enableBashIntegration = true;
    # enableZshIntegration = true;
    nix-direnv.enable = true;

    # Tempted... we'll see if it keeps annoying me
    silent = false;

    # Pulumi repos use mise
    mise.enable = true;
  };

  # direnv-instant = {
  #   enable = true;
  #   enableBashIntegration = true;
  #   enableZshIntegration = true;
  #   enableKittyIntegration = config.dotfiles.kitty.enable;
  # };
}
