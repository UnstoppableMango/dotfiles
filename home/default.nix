{ pkgs, lib, ... }:
{
  # Erik's preferences: git identity/aliases, kitty colors, k9s skin, GNOME
  # dconf taste, the ai/vscode/zed setup, and the sops secrets. `account.nix`
  # is generic account mechanics with no identity of its own, so the only
  # erik-specific bit here is the username default below, and it's an
  # `mkDefault` a consumer can override without a conflict.
  imports = [
    ./account.nix
    ./direnv.nix
    ./git.nix
    ./gnome.nix
    ./taste.nix
    ./vscode
  ];

  home.username = lib.mkDefault "erik";

  home.packages = with pkgs; [
    buf
    clan-cli
    devctl
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

  # Encrypted to both of erik's age keys (see .sops.yaml), so these decrypt on
  # darter and hades alike. Edit with `sops home/secrets/<file>.yaml`.
  sops.secrets = {
    "oco-api-key" = {
      sopsFile = ./secrets/opencommit.yaml;
      key = "oco_api_key";
    };

    "openrouter-api-key" = {
      sopsFile = ./secrets/openrouter.yaml;
      key = "openrouter_api_key";
    };
  };

  programs = {
    ripgrep-all.enable = true;

    bat.enable = true;
    eza.enable = true;
    zoxide = {
      enable = true;
      enableZshIntegration = true;
    };

    micro.enable = true;

    # Disabled: yt-dlp depends on curl-cffi, whose test suite currently fails
    # to build in nixpkgs (SSL error message regex mismatch in test_verify).
    # Re-enable once upstream is fixed.
    yt-dlp.enable = false;
  };
}
