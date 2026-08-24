{ lib, config, ... }:
let
  cfg = config.dotfiles.kubernetes.rosequartz;

  # The admin identity is clan-generated material that only the nixos repo can
  # supply. Without both halves we emit the OIDC context alone.
  adminEnabled = cfg.admin.certFile != null && cfg.admin.keyFile != null;

  lines = [
    "apiVersion: v1"
    "kind: Config"
    "clusters:"
    "- cluster:"
    "    certificate-authority: ${cfg.caFile}"
    "    server: ${cfg.server}"
    "  name: ${cfg.clusterName}"
    "contexts:"
  ]
  ++ lib.optionals adminEnabled [
    "- context:"
    "    cluster: ${cfg.clusterName}"
    "    user: ${cfg.clusterName}-admin"
    "  name: ${cfg.clusterName}"
  ]
  ++ [
    "- context:"
    "    cluster: ${cfg.clusterName}"
    "    user: ${cfg.clusterName}-github"
    "  name: ${cfg.clusterName}-github"
  ]
  ++ lib.optional (cfg.currentContext != null) "current-context: ${cfg.currentContext}"
  ++ [ "users:" ]
  ++ lib.optionals adminEnabled [
    "- name: ${cfg.clusterName}-admin"
    "  user:"
    "    client-certificate: ${cfg.admin.certFile}"
    "    client-key: ${cfg.admin.keyFile}"
  ]
  ++ [
    "- name: ${cfg.clusterName}-github"
    "  user:"
    "    exec:"
    "      apiVersion: client.authentication.k8s.io/v1"
    "      command: kubectl"
    "      args:"
    "        - oidc-login"
    "        - get-token"
    "        - --oidc-issuer-url=${cfg.oidc.issuerUrl}"
    "        - --oidc-client-id=${cfg.oidc.clientId}"
  ]
  ++ map (scope: "        - --oidc-extra-scope=${scope}") cfg.oidc.extraScopes
  ++ [
    "      installHint: |"
    "        kubelogin plugin not found. Install: https://github.com/int128/kubelogin"
    "      interactiveMode: IfAvailable"
  ];

  # Assembled line by line rather than as an indented string literal: the
  # admin blocks are conditional, and interpolating multi-line chunks into a
  # '' block would not re-indent them.
  rendered = lib.concatMapStrings (line: line + "\n") lines;
in
{
  options.dotfiles.kubernetes.rosequartz = {
    enable = lib.mkEnableOption "kubeconfig for the rosequartz cluster";

    clusterName = lib.mkOption {
      type = lib.types.str;
      default = "rosequartz";
      description = ''
        Cluster name, and the stem for the `<name>-admin` and `<name>-github`
        context and user names.
      '';
    };

    server = lib.mkOption {
      type = lib.types.str;
      default = "https://10.0.69.100:6443";
      description = ''
        Control plane endpoint. This is the loadbalancer VIP, not a machine,
        which is why it does not live in hosts.nix: the nixos repo maps every
        hosts.nix entry 1:1 onto a clan machine in the `internet` service.
      '';
    };

    caFile = lib.mkOption {
      type = lib.types.str;
      default = toString ./ca.crt;
      description = ''
        Path to the cluster CA certificate.

        The default is a copy of the nixos repo's
        `vars/shared/rosequartz-ca/crt/value`, which is the source of truth.
        It is duplicated here because that repo depends on this one, so the
        import cannot go the other way. Re-copy it if the CA is ever rotated.
        The nixos repo overrides this with the real vars path.
      '';
    };

    admin = {
      certFile = lib.mkOption {
        type = with lib.types; nullOr str;
        default = null;
        description = ''
          Path to the admin client certificate. Clan-generated, so only the
          nixos repo can set it. The admin context and user are omitted unless
          both this and `admin.keyFile` are set.
        '';
      };

      keyFile = lib.mkOption {
        type = with lib.types; nullOr str;
        default = null;
        description = ''
          Path to the admin client key, as decrypted onto disk by sops-nix.
        '';
      };
    };

    oidc = {
      issuerUrl = lib.mkOption {
        type = lib.types.str;
        default = "https://dex.thecluster.io";
        description = "OIDC issuer for the `<name>-github` user.";
      };

      clientId = lib.mkOption {
        type = lib.types.str;
        default = "rosequartz-kubernetes";
        description = "OIDC client id for the `<name>-github` user.";
      };

      extraScopes = lib.mkOption {
        type = with lib.types; listOf str;
        default = [ "groups" ];
        description = "Extra scopes requested by `kubectl oidc-login`.";
      };
    };

    currentContext = lib.mkOption {
      type = with lib.types; nullOr str;
      default = null;
      description = ''
        Value for `current-context`, or null to omit the key entirely.
        Leave it null when this file is merged into KUBECONFIG alongside a
        writable kubeconfig that already picks the context.
      '';
    };

    target = lib.mkOption {
      type = lib.types.str;
      default = ".kube/rosequartz.yaml";
      description = "Destination, relative to the home directory.";
    };

    sopsTemplate = lib.mkOption {
      type = with lib.types; nullOr str;
      default = null;
      description = ''
        When set, render into `sops.templates.<name>` instead of `home.file`,
        which produces a real file with `mode` rather than a read-only store
        symlink. Requires sops-nix and at least one `sops.secrets` entry.
      '';
    };

    mode = lib.mkOption {
      type = lib.types.str;
      default = "0600";
      description = "File mode. Only meaningful together with `sopsTemplate`.";
    };
  };

  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        assertions = [
          {
            assertion = cfg.sopsTemplate == null || config.sops.secrets != { };
            message = ''
              dotfiles.kubernetes.rosequartz.sopsTemplate needs at least one
              sops.secrets entry: sops-nix renders templates from an
              activation script it gates on `sops.secrets != {}`, so the file
              would silently never appear.
            '';
          }
          {
            assertion = (cfg.admin.certFile == null) == (cfg.admin.keyFile == null);
            message = ''
              dotfiles.kubernetes.rosequartz.admin.certFile and
              admin.keyFile must be set together.
            '';
          }
        ];
      }

      (lib.mkIf (cfg.sopsTemplate == null) {
        home.file.${cfg.target}.text = rendered;
      })

      (lib.mkIf (cfg.sopsTemplate != null) {
        sops.templates.${cfg.sopsTemplate} = {
          path = "${config.home.homeDirectory}/${cfg.target}";
          inherit (cfg) mode;
          content = rendered;
        };
      })
    ]
  );
}
