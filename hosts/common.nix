{ inputs }:
{
  self,
  config,
  pkgs,
  lib,
  ...
}:
{
  nixpkgs.overlays = [ self.overlays.default ];
  nixpkgs.config.allowUnfree = true;
  # BizHawk's Mono WinForms runtime has no gtk3 port; nixpkgs drops gtk2 before 27.05.
  nixpkgs.config.problems.handlers."gtk+".broken = "warn";

  # Home Manager asserts `nix.package != null` whenever `nix.settings` is set.
  nix.package = lib.mkDefault pkgs.nix;
  nix.settings = {
    extra-substituters = [ "https://unstoppablemango.cachix.org" ];
    extra-trusted-public-keys = [
      "unstoppablemango.cachix.org-1:m7uEI6X1Ov8DyFWJQX4WsRFRWFuzRW5c/Xms8ZaP74U="
    ];
  };
  # `!include` skips a missing file, where a bare `include` would fail.
  nix.extraOptions = "!include ${config.xdg.configHome}/nix/nix.conf.local";

  dotfiles.ssh.hosts = inputs.hosts.lib.addresses;
  # Public DNS points at Cloudflare's proxy, which does not carry port 22.
  programs.ssh.settings."gitea.thecluster.io".HostName = "gitea.thecluster.lan";
  dotfiles.ai.mattpocock.src = inputs.mattpocock-skills;
}
