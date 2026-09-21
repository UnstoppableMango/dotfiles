{
  pkgs,
  nix2container,
  hm,
}:
let
  inherit (hm.config.home) username homeDirectory path;

  # Activation needs a writable home, so it cannot run at build time.
  # home-files is the symlink tree activation would link into place, so it is
  # copied in directly instead.
  homeRoot = pkgs.runCommand "container-home" { } ''
    mkdir -p $out${homeDirectory} $out/tmp
    cp -a ${hm.activationPackage}/home-files/. $out${homeDirectory}/
  '';

  # Kept out of homeRoot: nix2container rejects a directory that appears in two
  # copyToRoot entries with different perms, and base also provides /etc.
  accounts = pkgs.runCommand "container-accounts" { } ''
    mkdir -p $out/etc
    cat > $out/etc/passwd <<EOF
    root:x:0:0::/root:/bin/sh
    ${username}:x:1000:1000::${homeDirectory}:${path}/bin/zsh
    EOF
    cat > $out/etc/group <<EOF
    root:x:0:
    ${username}:x:1000:
    EOF
  '';

  base = pkgs.buildEnv {
    name = "container-base";
    paths = with pkgs; [
      accounts
      bashInteractive
      cacert
      coreutils
    ];
    pathsToLink = [
      "/bin"
      "/etc"
    ];
  };
in
nix2container.buildImage {
  name = "ghcr.io/unstoppablemango/dotfiles";
  tag = "latest";
  maxLayers = 100;
  copyToRoot = [
    base
    homeRoot
  ];
  perms = [
    {
      path = homeRoot;
      # Matched against the full store path, so no ^ anchor.
      regex = "${homeDirectory}";
      mode = "0755";
      uid = 1000;
      gid = 1000;
      uname = username;
      gname = username;
    }
    {
      path = homeRoot;
      regex = "/tmp$";
      mode = "1777";
    }
  ];
  config = {
    User = username;
    WorkingDir = homeDirectory;
    Cmd = [
      "${path}/bin/zsh"
      "-l"
    ];
    Env = [
      "HOME=${homeDirectory}"
      "USER=${username}"
      "PATH=${path}/bin:/bin"
      "SSL_CERT_FILE=${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
    ];
  };
}
