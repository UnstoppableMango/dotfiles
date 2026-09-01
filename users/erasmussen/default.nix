{ pkgs, ... }:
let
  username = "erasmussen";
in
{
  imports = [
    ../../modules
    ../shared
  ];

  home = {
    inherit username;
    homeDirectory = "/Users/${username}";

    # nix-darwin's homebrew module drives `brew bundle` by absolute path and
    # never touches PATH, so `cci` and friends need this to be reachable.
    sessionPath = [ "/opt/homebrew/bin" ];

    packages = with pkgs; [
      buf
      clan-cli
      crane
      devctl
      fnm
      gitkraken
      glow
      pay-respects
      pwgen
      slackdump
      spotify
      vhs
    ];
  };

  dotfiles = {
    ai.enable = true;
    neovim.enable = true;
    vscode.enable = true;
    zsh.enable = true;
    # The app itself comes from the Homebrew cask in darwin/erasmussen; the
    # module sets programs.ghostty.package to null on darwin, so Home Manager
    # only writes ~/.config/ghostty/config for it.
    ghostty.enable = true;
    kitty.enable = true;
    zed.enable = true;
    c.enable = true;
    containers.enable = true;
    containers.podmanAutostart = true;
    dotnet.enable = true;

    git = {
      enable = true;
      openCommit = {
        enable = true;
        apiKeySecret = "oco-api-key";
        settings = {
          OCO_AI_PROVIDER = "anthropic";
          OCO_MODEL = "claude-sonnet-4-6";
          OCO_GITPUSH = false;
        };
      };
    };

    # 1Password owns SSH keys and commit signing on this machine, so gpg-agent
    # would only contend for SSH_AUTH_SOCK. macOS also has no pinentry wired up
    # in modules/gnupg, which leaves gpg with no way to prompt for a passphrase.
    gnupg.enable = false;
    onePassword = {
      enable = true;
      # TODO: paste the public half of the 1Password SSH key here. Until it is
      # set, git has no signing key and `commit.gpgsign = true` (users/shared)
      # will reject commits. See docs/onboarding.md.
      signingKey = null;
    };

    go.enable = true;
    javascript.enable = true;
    kubernetes.enable = true;
    nix.enable = true;
    openshift.enable = false;
    ocaml.enable = true;
    python.enable = true; # also the uv that programs.uv.tool below rides on
    sops.enable = true;
    fonts.enable = true;
    ssh.enable = true;
    stylix.enable = true;
  };

  # Edit with `sops users/erasmussen/secrets/<file>.yaml`.
  sops.secrets = {
    "oco-api-key" = {
      sopsFile = ./secrets/opencommit.yaml;
      key = "oco_api_key";
    };
  };

  programs = {
    # Let Home Manager install and manage itself
    home-manager.enable = true;

    # Salesforce CumulusCI, which provides `cci`. It is not in nixpkgs and its
    # Homebrew formula was disabled upstream in 2022, leaving PyPI as the only
    # route, so Home Manager drives `uv tool install` on activation instead of
    # the tool landing in home.packages. Executables go to ~/.local/bin, which
    # modules/toolchain/python already puts on PATH.
    #
    # This list merges with modules/ai/omnigent.nix, which declares omnigent
    # through the same option, so the declared set already covers everything
    # installed. `tool.prune` stays off anyway, so an ad-hoc `uv tool install`
    # survives the next activation instead of being silently reverted.
    uv.tool.packages = [ "cumulusci" ];

    grep.enable = true;
    htop.enable = true;
    fzf.enable = true;
    jq.enable = true;
    less.enable = true;

    ripgrep.enable = true;
    ripgrep-all.enable = true;

    bat.enable = true;
    eza.enable = true;
    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };

    vim.enable = true;
    micro.enable = true;

    direnv = {
      enable = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
    };

    # direnv-instant = {
    #   enable = true;
    #   enableBashIntegration = true;
    #   enableZshIntegration = true;
    #   enableKittyIntegration = config.dotfiles.kitty.enable;
    # };
  };

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "26.05"; # Please read the comment before changing.
}
