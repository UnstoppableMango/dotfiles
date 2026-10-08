{ pkgs, lib, ... }:
{
  imports = [
    ./account.nix
    ./direnv.nix
    ./git.nix
    ./gnome.nix
    ./ssh.nix
    ./vscode
    ./vscodium.nix
  ];

  home.username = lib.mkDefault "erik";

  home.packages = with pkgs; [
    buf
    clan-cli
    devctl
    dix
    glow
    mise
    nano
    fastfetch
    openssl
    pay-respects
    pv
    slackdump
    vhs
  ];

  # Edit with `sops home/secrets/<file>.yaml`.
  sops.secrets."openrouter-api-key" = {
    sopsFile = ./secrets/openrouter.yaml;
    key = "openrouter_api_key";
  };

  dotfiles.openrouter.apiKeySecret = "openrouter-api-key";

  # Fine-grained PAT for the GitHub MCP server; see docs/github-token.md.
  sops.secrets."github-pat" = {
    sopsFile = ./secrets/github.yaml;
    key = "github_pat";
  };

  dotfiles.github.token.secret = "github-pat";

  programs = {
    ripgrep-all.enable = true;

    bat.enable = true;
    eza.enable = true;
    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };

    micro.enable = true;

    # Its curl-cffi dependency fails test_verify in nixpkgs.
    yt-dlp.enable = false;
  };
}
