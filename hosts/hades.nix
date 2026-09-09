{
  config,
  pkgs,
  ...
}:
{
  imports = [
    ../home
    ../home/vscode/hades.nix
    ../profiles/base.nix
    ../profiles/dev.nix
    ../profiles/ai.nix
    ../profiles/workstation.nix
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
    ocaml.enable = true;
    dotnet.enable = true;
    emacs.enable = true;

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

  programs.lutris.enable = true;

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
