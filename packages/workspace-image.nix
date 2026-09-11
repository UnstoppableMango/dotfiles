{
  lib,
  bashInteractive,
  cacert,
  coreutils,
  dockerTools,
  gitMinimal,
  nix,
  openssh,
  writeShellApplication,
  writeTextDir,

  # The evaluated `homeConfigurations."erik@workspace"`. Everything the image
  # holds comes out of it, so the container and a real machine run the same
  # toolchain from the same pin.
  homeConfiguration,

  name ? "workspace",
  tag ? "latest",
}:
let
  hm = homeConfiguration.config;
  rc = hm.dotfiles.ai.remoteControl;

  inherit (hm.home) username homeDirectory;
  uid = 1000;
  gid = 100;

  # dockerTools' own fakeNss only knows nobody, and the whole image is built
  # around one named account.
  passwd = writeTextDir "etc/passwd" ''
    root:x:0:0:System administrator:/root:${lib.getExe bashInteractive}
    ${username}:x:${toString uid}:${toString gid}:${username}:${homeDirectory}:${lib.getExe bashInteractive}
    nobody:x:65534:65534:Nobody:/var/empty:/bin/false
  '';

  group = writeTextDir "etc/group" ''
    root:x:0:
    users:x:${toString gid}:
    nogroup:x:65534:
  '';

  # Without this, glibc falls back to NSS modules that are not in the image and
  # `getent passwd` comes up empty, which git and ssh both notice.
  nsswitch = writeTextDir "etc/nsswitch.conf" ''
    passwd:    files
    group:     files
    shadow:    files
    hosts:     files dns
  '';

  entrypoint = writeShellApplication {
    name = "workspace-entrypoint";
    runtimeInputs = [
      coreutils
      nix
    ];
    text = ''
      # Home Manager's activation script writes the dotfile tree and the
      # profile symlinks, both of which live in the container's writable layer
      # rather than the image. Running it on every start keeps a bind-mounted
      # home in sync with whatever generation the image was built from; the
      # backup extension keeps a pre-existing file in a mounted home from
      # aborting it.
      export HOME=${lib.escapeShellArg homeDirectory}
      export USER=${lib.escapeShellArg username}
      export HOME_MANAGER_BACKUP_EXT=hm-bak

      mkdir -p "$HOME" ${lib.escapeShellArg rc.rootDir}
      ${homeConfiguration.activationPackage}/activate

      cd ${lib.escapeShellArg rc.rootDir}

      # The server registers with Anthropic over outbound HTTPS and opens no
      # inbound port, so it needs no container port published. Credentials come
      # from a mounted $HOME/.claude; without one it exits asking for a login.
      exec ${lib.getExe hm.programs.claude-code.finalPackage} remote-control \
        --spawn ${lib.escapeShellArg rc.spawn} \
        --permission-mode ${lib.escapeShellArg rc.permissionMode} \
        "$@"
    '';
  };
in
# `withNixDb` rather than plain `buildLayeredImage`: Home Manager activation
# calls `nix-store --realise` and `nix-env --set`, which need a store database
# describing the paths the image already carries.
dockerTools.buildLayeredImageWithNixDb {
  inherit name tag;

  contents = [
    # The activation package pulls `home.path` (every `home.packages` entry and
    # every program the profiles enable) in as a dependency, so listing it
    # brings the whole toolchain.
    homeConfiguration.activationPackage
    entrypoint

    bashInteractive
    cacert
    coreutils
    gitMinimal
    nix
    openssh

    passwd
    group
    nsswitch

    dockerTools.usrBinEnv
    dockerTools.binSh
  ];

  # `contents` lands in the image read-only and root-owned. Activation writes
  # to the Nix state directory (profiles, gcroots, the database it was just
  # given), so the account it runs as has to own that.
  fakeRootCommands = ''
    mkdir -p ./${homeDirectory} ./tmp ./nix/var/nix/profiles/per-user/${username} ./nix/var/nix/gcroots/per-user/${username}
    chmod 1777 ./tmp
    chown -R ${toString uid}:${toString gid} ./${homeDirectory} ./nix/var

    # Nix creates `.links` when it first opens a store it can write to, and it
    # is the one directory under /nix/store the account needs. Creating it here
    # keeps that out of the container's startup path and the rest of the store
    # root-owned.
    mkdir -p ./nix/store/.links
    chown ${toString uid}:${toString gid} ./nix/store/.links ./nix/store
  '';

  # Deliberately not `enableFakechroot`: that variant tars the customisation
  # layer with `--exclude=./nix/store`, which drops the `.links` directory
  # above along with the ownership this layer is here to set.

  config = {
    Entrypoint = [ (lib.getExe entrypoint) ];
    WorkingDir = rc.rootDir;
    User = "${toString uid}:${toString gid}";

    Env = [
      "HOME=${homeDirectory}"
      "USER=${username}"
      "PATH=${homeDirectory}/.nix-profile/bin:${
        lib.makeBinPath [
          bashInteractive
          coreutils
          gitMinimal
          nix
          openssh
        ]
      }"
      "SSL_CERT_FILE=${cacert}/etc/ssl/certs/ca-bundle.crt"
      "NIX_SSL_CERT_FILE=${cacert}/etc/ssl/certs/ca-bundle.crt"
      "TERM=xterm-256color"
      # Single-user store in the image, so there is no daemon to talk to.
      "NIX_REMOTE="
    ];

    # No `Volumes`. Declaring one makes the runtime create an anonymous volume
    # owned by root, which the account this runs as then cannot write, and
    # Home Manager activation writes under `.claude` on every start. The mounts
    # this image expects are in README.md instead.

    Labels = {
      "org.opencontainers.image.title" = "UnstoppableMango workspace";
      "org.opencontainers.image.description" =
        "Claude Code Remote Control workspace built from the dotfiles home configuration";
      "org.opencontainers.image.source" = "https://github.com/UnstoppableMango/dotfiles";
    };
  };
}
