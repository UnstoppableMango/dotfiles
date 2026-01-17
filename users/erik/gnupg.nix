{
  flake.modules.homeManager.erik = { pkgs, ... }: {
    programs.gpg.enable = true;
    services.gpg-agent = {
      enable = true;
      enableSshSupport = true;
      enableZshIntegration = true;
      pinentry = {
        package = pkgs.pinentry-all;
        program = "pinentry-gnome3";
      };
    };
  };
}
