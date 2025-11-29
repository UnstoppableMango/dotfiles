NIX         ?= nix
HOMEMANAGER ?= home-manager
WATCHEXEC   ?= watchexec

SRC != find -path '*.nix' -printf '%P\n'

build:
	$(HOMEMANAGER) build --flake ${CURDIR}

check:
	$(NIX) flake check

watch:
	$(WATCHEXEC) -e nix $(NIX) flake check

update: flake.lock

home:
	$(NIX) flake update --flake ${HOME}/.config/home-manager
	$(HOMEMANAGER) switch --flake ${HOME}/.config/home-manager -b hm-backup

system:
	sudo $(NIX) flake update --flake /etc/nixos
	sudo nixos-rebuild switch --flake /etc/nixos

format fmt:
	$(NIX) fmt

flake.lock: ${SRC}
	$(NIX) flake update

flake.nix:
	$(NIX) flake init

.PHONY: flake.lock
