# Single source of truth for how to reach each machine on the network.
#
# Consumed by:
#   - dotfiles' ssh module (modules/ssh), which turns these into Host blocks
#     so every one of erik's machines can `ssh <name>`.
#   - the nixos repo's `internet` clan service (deploys, `clan ssh`), which
#     imports this file through the `dotfiles` flake input.
{
  agreus = "10.0.69.187";
  hades = "192.168.1.69";
  pik8s1 = "192.168.1.101";
  pik8s2 = "192.168.1.102";
  pik8s3 = "192.168.1.103";
  pik8s4 = "10.0.69.104";
  pik8s5 = "10.0.69.105";
  pik8s6 = "10.0.69.106";
}
