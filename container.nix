{
  pkgs,
  lib,
  nix2container,
  username,
  homeDirectory,
  putterManifest,
  path,
}:
let
  # The image carries no store paths. The pod mounts a nix-daemon's store over
  # /nix, which would hide them anyway, and realises `env` through that daemon
  # at start: an ordinary substitution from the binary cache, kept on the
  # store's volume across restarts. Everything the image does ship is a real,
  # statically linked file outside /nix.
  #
  # Kept in sync with `env`'s out-link in `dotfiles-env` below.
  profile = "${homeDirectory}/.local/state/dotfiles/profile";

  # Home files are placed at start rather than baked in, so $HOME can be a
  # volume. Home Manager's activate script needs nix, but its putter file
  # activator does not: this is the whole of linkGeneration in putter mode.
  # The state file sits in $HOME, so files a later image drops are removed.
  hmFiles = pkgs.writeShellApplication {
    name = "hm-files";
    runtimeInputs = [ pkgs.putter ];
    text = ''
      putter apply \
        --state-file "$HOME/.local/state/home-manager/putter-state.json" \
        ${putterManifest}
      exec "$@"
    '';
  };

  # What the pod realises: the Home Manager profile, hm-files, and a bash for
  # /bin/sh.
  env = pkgs.symlinkJoin {
    name = "dotfiles-container-env";
    paths = [
      path
      hmFiles
      pkgs.bashInteractive
    ];
  };

  # Real files under /usr/local, statically linked and with their store
  # references nuked, the same technique as unmango/containers'
  # actions-runner image: a mount over /nix leaves them working.
  tools =
    pkgs.runCommand "container-tools"
      {
        nativeBuildInputs = [ pkgs.nukeReferences ];
      }
      ''
        mkdir -p $out/usr/local/bin
        copyStatic() {
          cp -L "$1" "$out/usr/local/bin/$2"
          chmod +w "$out/usr/local/bin/$2"
          nuke-refs "$out/usr/local/bin/$2"
          chmod 0555 "$out/usr/local/bin/$2"
        }

        copyStatic ${pkgs.pkgsStatic.nix}/bin/nix nix
        # The legacy commands are the same binary, dispatched on its name.
        for cmd in nix-build nix-channel nix-collect-garbage nix-copy-closure \
          nix-daemon nix-env nix-hash nix-instantiate nix-prefetch-url nix-shell nix-store; do
          ln -s nix "$out/usr/local/bin/$cmd"
        done

        # Runs the entrypoints below, and serves as the sandbox's /bin/sh.
        copyStatic ${pkgs.pkgsStatic.busybox}/bin/busybox busybox
        ln -s busybox $out/usr/local/bin/sh

        # Rootless podman maps its subordinate ids through these. They must be
        # setuid, which the store forbids; see `perms`.
        copyStatic ${pkgs.pkgsStatic.shadow}/bin/newuidmap newuidmap
        copyStatic ${pkgs.pkgsStatic.shadow}/bin/newgidmap newgidmap
      '';

  # Starts the daemon over whatever volume is at /nix. Kubelet hands a volume
  # over as root:fsGroup with the setgid bit, which every directory nix creates
  # would inherit, so /nix is reset first. Five digits, because a numeric chmod
  # of four or fewer keeps setgid.
  daemonEntrypoint = pkgs.writeTextDir "usr/local/bin/dotfiles-daemon" ''
    #!/usr/local/bin/sh
    set -eu
    busybox chown 0:0 /nix
    busybox chmod 00755 /nix
    exec nix-daemon
  '';

  # Realises the pinned profile through the daemon, then runs its arguments
  # with the profile on PATH. The out-link is an indirect GC root, so the
  # daemon keeps the profile until a later image replaces the link.
  envEntrypoint = pkgs.writeTextDir "usr/local/bin/dotfiles-env" ''
    #!/usr/local/bin/sh
    set -eu
    export NIX_REMOTE=daemon
    busybox mkdir -p "$(busybox dirname ${profile})"
    nix-store --realise "$(busybox cat /etc/dotfiles/profile)" \
      --add-root ${profile} --indirect >/dev/null
    export SHELL=${profile}/bin/zsh
    exec "$@"
  '';

  # nixbld1-32 fall inside the 65536 uids a user-namespaced pod maps.
  nixbldUsers = lib.genList (
    i: "nixbld${toString (i + 1)}:x:${toString (30001 + i)}:30000::/var/empty:/usr/local/bin/sh"
  ) 32;

  etc = pkgs.runCommand "container-etc" { } ''
    mkdir -p $out/etc/nix $out/etc/dotfiles $out/etc/ssl/certs

    cat > $out/etc/passwd <<EOF
    root:x:0:0::/root:/usr/local/bin/sh
    ${username}:x:1000:1000::${homeDirectory}:${profile}/bin/zsh
    ${lib.concatStringsSep "\n" nixbldUsers}
    EOF
    cat > $out/etc/group <<EOF
    root:x:0:
    ${username}:x:1000:
    nixbld:x:30000:${lib.concatMapStringsSep "," (i: "nixbld${toString i}") (lib.range 1 32)}
    EOF

    # The pod maps 65536 uids, so rootless podman gets the ones above this
    # user's own.
    echo "${username}:1001:64535" > $out/etc/subuid
    echo "${username}:1001:64535" > $out/etc/subgid

    # A copy, not a link: the store it lives in is hidden at run time.
    cp ${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt $out/etc/ssl/certs/ca-bundle.crt

    # The path alone, without its closure: the pod fetches it.
    echo ${builtins.unsafeDiscardStringContext env} > $out/etc/dotfiles/profile

    cat > $out/etc/nix/nix.conf <<EOF
    experimental-features = nix-command flakes
    build-users-group = nixbld
    sandbox = true
    sandbox-fallback = false
    sandbox-paths = /bin/sh=/usr/local/bin/busybox
    use-xdg-base-directories = true
    substituters = https://cache.nixos.org https://unstoppablemango.cachix.org
    trusted-public-keys = cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY= unstoppablemango.cachix.org-1:m7uEI6X1Ov8DyFWJQX4WsRFRWFuzRW5c/Xms8ZaP74U=
    # Collect garbage while building once the volume runs low.
    min-free = ${toString (20 * 1024 * 1024 * 1024)}
    max-free = ${toString (40 * 1024 * 1024 * 1024)}
    EOF
  '';

  # /bin/sh and /usr/bin/env resolve into the profile, which exists once
  # `dotfiles-env` has run; make and env-shebang scripts need both.
  links = pkgs.runCommand "container-links" { } ''
    mkdir -p $out/bin $out/usr/bin
    ln -s ${profile}/bin/bash $out/bin/sh
    ln -s ${profile}/bin/env $out/usr/bin/env
  '';

  dirs = pkgs.runCommand "container-dirs" { } ''
    mkdir -p $out${homeDirectory} $out/tmp $out/nix $out/root
  '';
in
{
  inherit env;

  image = nix2container.buildImage {
    name = "ghcr.io/unstoppablemango/dotfiles";
    tag = "latest";

    copyToRoot = [
      tools
      daemonEntrypoint
      envEntrypoint
      etc
      links
      dirs
    ];

    perms = [
      {
        path = daemonEntrypoint;
        regex = "dotfiles-daemon$";
        mode = "0555";
      }
      {
        path = envEntrypoint;
        regex = "dotfiles-env$";
        mode = "0555";
      }
      {
        path = tools;
        regex = "new[ug]idmap$";
        mode = "4755";
        uid = 0;
        gid = 0;
      }
      {
        path = dirs;
        # Matched against the full store path, so no ^ anchor.
        regex = "${homeDirectory}$";
        mode = "0755";
        uid = 1000;
        gid = 1000;
        uname = username;
        gname = username;
      }
      {
        path = dirs;
        regex = "/tmp$";
        mode = "1777";
      }
    ];

    config = {
      User = username;
      WorkingDir = homeDirectory;

      Env = [
        "HOME=${homeDirectory}"
        "USER=${username}"
        "PATH=/usr/local/bin:${profile}/bin"
        "NIX_SSL_CERT_FILE=/etc/ssl/certs/ca-bundle.crt"
        "SSL_CERT_FILE=/etc/ssl/certs/ca-bundle.crt"
      ];
    };
  };
}
