{
  flake.modules.homeManager.ocaml = {
    programs.opam = {
      enable = true;
      enableZshIntegration = true;
    };
  };
}
