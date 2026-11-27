# Toolchains

`c/`, `containers/`, `dotnet/`, `git/`, `go/`, `javascript/`, `kubernetes/`, `nix/`, `ocaml/`, `python/`, and `rust/` hold per-language dev tooling.
Git has its own page: [git](git.md).

## tdl

There is no `tdl/` module.
The tdl flake exports `homeModules.tdl` declaring `programs.tdl.*` (the CLI plus the VS Code extension), which `homeModules.dotfiles` folds in, so a host sets `programs.tdl.enable`.

## containers/

- podman (with buildah, skopeo, podman-compose) and `docker-client` side by side; the CLI without the daemon, since a system dockerd is outside Home Manager's reach.
- `docker compose` and `docker buildx` are linked into `~/.docker/cli-plugins`, because the CLI resolves subcommands there rather than from PATH.
- podman-tui follows `dotfiles.containers.tui`, on by default.
- `REGISTRY_AUTH_FILE` points podman, skopeo, and buildah at `~/.docker/config.json`, so one `docker login` serves both (`dotfiles.containers.sharedAuth`).
- `dotfiles.containers.podmanSocket` and `.userRegistryConfig` default to `targets.genericLinux.enable`.
  Non-NixOS hosts get the rootless `podman.socket`/`podman.service` user units and `~/.config/containers/{policy.json,registries.conf}`, which the podman package carries no defaults for.
  NixOS hosts keep the system layer's units and `/etc/containers` authoritative.
- `dotfiles.containers.registryCAs` writes a CA per registry host to `~/.config/containers/certs.d/<host>/ca.crt` for the rootless stack.
  A system dockerd reads only `/etc/docker/certs.d`.

## kubernetes/

Submodules `k9s/`, `openshift/`, and `rosequartz/`, aggregated through `default.nix`.

`rosequartz/` owns the shape of the rosequartz kubeconfig (contexts, VIP, Keycloak OIDC exec block).
A host supplies the admin cert and key paths; omitting them yields the OIDC context alone, which is what darter takes.
It also installs `kubelogin-oidc`, the `kubectl oidc-login` plugin that context calls.
