{ config, ... }:
{
  imports = [
    ./emacs
    ./helix
    ./nano
    ./neovim
    ./vscode
    ./zed
  ];

  flake.modules.homeManager.editors = {
    imports = with config.flake.modules.homeManager; [
      emacs
      helix
      nano
      neovim
      vscode
      zed
    ];
  };
}
