{
  flake.modules.homeManager.javascript =
    { pkgs, ... }:
    {
      home.packages = with pkgs; [
        fnm
      ];

      programs.zsh.initContent = ''
        eval "$(fnm env --use-on-cd --shell zsh)"
      '';
    };
}
