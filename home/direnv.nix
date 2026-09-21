{
  programs = {
    direnv = {
      enable = true;
      # enableBashIntegration = true;
      # enableZshIntegration = true;
      nix-direnv.enable = true;

      silent = false;

      # Pulumi repos use mise
      mise.enable = true;
    };

    direnv-instant.enable = true;
  };
}
