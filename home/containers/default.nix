{ config, lib, ... }:
{
  # The-cluster's Nixery, behind a gateway whose chain ends at one of these:
  # the pre-ceremony CA it serves today, and the UnMango Root CA G2 it moves to.
  # Copies of the nixos repo's modules/pki/{thecluster-lan-nginx-ca,ca}.pem.
  config.dotfiles.containers.registryCAs = lib.mkIf config.dotfiles.containers.enable {
    "nixery.thecluster.lan" = ./thecluster-lan-ca.crt;
  };
}
