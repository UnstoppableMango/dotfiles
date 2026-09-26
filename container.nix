{
  pkgs,
  nix2container,
  username,
  homeDirectory,
  putterManifest,
  path,
}:
let
  # Home files are placed at start rather than baked in, so $HOME can be a
  # volume. Home Manager's activate script needs nix, but its putter file
  # activator does not: this is the whole of linkGeneration in putter mode.
  # The state file sits in $HOME, so files a later image drops are removed.
  entrypoint = pkgs.writeShellApplication {
    name = "hm-files";
    runtimeInputs = [ pkgs.putter ];
    text = ''
      putter apply \
        --state-file "$HOME/.local/state/home-manager/putter-state.json" \
        ${putterManifest}
      exec "$@"
    '';
  };

  homeRoot = pkgs.runCommand "container-home" { } ''
    mkdir -p $out${homeDirectory} $out/tmp
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

    Entrypoint = [ "${entrypoint}/bin/hm-files" ];
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
