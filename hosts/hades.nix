{
  config,
  pkgs,
  ...
}:
{
  imports = [
    ../home
    ../home/vscode/hades.nix
  ];

  programs.git.settings = {
    user.signingkey = "B4986C137EB15A0C91FB69FE264283BBFDC491BC";
    gpg.format = "openpgp";
  };

  # The admin identity for the rosequartz cluster. Clan-generated in the nixos
  # repo, vendored here so this configuration stands on its own; see the
  # `caFile` option's description for the same reasoning about the CA.
  sops.secrets = {
    "rosequartz-admin-cert" = {
      sopsFile = ../home/secrets/rosequartz.yaml;
      key = "admin_cert";
    };

    "rosequartz-admin-key" = {
      sopsFile = ../home/secrets/rosequartz.yaml;
      key = "admin_key";
    };
  };

  dotfiles = {
    git.enable = true;
    gnupg.enable = true;
    nix.enable = true;
    onePassword.enable = true;
    sops.enable = true;
    ssh.enable = true;
    zsh.enable = true;

    c.enable = true;
    containers.enable = true;
    dotnet.enable = true;
    go.enable = true;
    javascript.enable = true;
    kubernetes.enable = true;
    ocaml.enable = true;
    python.enable = true;

    ai = {
      enable = true;
      claudeDesktop.enable = true;
    };

    brave.enable = true;
    emacs.enable = true;
    fonts.enable = true;
    ghostty.enable = true;
    gnome.enable = true;
    helix.enable = true;
    kitty.enable = true;
    neovim.enable = true;
    obsidian.enable = true;
    stylix.enable = true;
    vscode.enable = true;
    zed.enable = true;

    # Serve the omnigent web UI to the rest of the LAN, not just loopback, so
    # the desktop and mobile clients on other devices reach this host at
    # 10.0.69.69 / 192.168.1.69 / hades. Safe only because the machine sits
    # behind the house firewall: the server itself authenticates nothing.
    ai.omnigent.listenAddress = "0.0.0.0";

    # Keep this machine reachable from claude.ai/code and the mobile apps
    # without a terminal open. Outbound-only: the server registers with
    # Anthropic and opens no inbound port.
    ai.remoteControl.enable = true;

    # hades holds the admin identity, so it owns ~/.kube/config outright
    # rather than merging a side file into KUBECONFIG the way darter does.
    kubernetes.rosequartz = {
      enable = true;
      currentContext = "rosequartz";
      target = ".kube/config";
      sopsTemplate = "kube-config";
      admin.certFile = config.sops.secrets."rosequartz-admin-cert".path;
      admin.keyFile = config.sops.secrets."rosequartz-admin-key".path;
    };
  };

  programs = {
    home-manager.enable = true;
    lutris.enable = true;
    tdl.enable = true;

    fzf.enable = true;
    grep.enable = true;
    htop.enable = true;
    jq.enable = true;
    less.enable = true;
    ripgrep.enable = true;
    vim.enable = true;
  };

  home.packages = with pkgs; [
    devenv
    jetbrains-toolbox
    gitkraken
    bitwarden-cli
    cachix
    github-desktop
    seabird
    spotify
    discord
    tutanota-desktop
    slack
    signal-desktop
    claude-monitor
    xmage

    (wineWow64Packages.full.override {
      wineRelease = "staging";
      mingwSupport = true;
    })
    winetricks

    kdePackages.breeze
    kdePackages.breeze-icons
    paper-icon-theme
    vimix-icon-theme
    papirus-icon-theme
    gimp3
    firefox-devedition
    google-chrome
    vlc
  ];
}
