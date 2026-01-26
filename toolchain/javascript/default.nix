{
  flake.modules.homeManager.javascript =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        fnm
      ];

      programs.zsh.initContent = ''
        eval "$(${pkgs.fnm} env --use-on-cd --shell zsh)"
      '';
    };
}
