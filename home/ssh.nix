{
  # Each key's resident FIDO2 SSH credential. `ssh-keygen -K` in ~/.ssh
  # fetches the handles on a new machine.
  dotfiles.yubikey.keys = {
    nano.sshKey = "sk-ssh-ed25519@openssh.com AAAAGnNrLXNzaC1lZDI1NTE5QG9wZW5zc2guY29tAAAAICEHGscAv+7+QCt2KSWDX3MZYMXbcH7fYcbw6jRvItauAAAACHNzaDpuYW5v erik@yubikey-nano";
  };
}
