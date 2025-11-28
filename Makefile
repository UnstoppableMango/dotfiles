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

system:
	sudo nix flake update --flake /etc/nixos
	sudo nixos-rebuild switch --flake /etc/nixos

format fmt:
	$(NIX) fmt

flake.lock: ${SRC}
	$(NIX) flake update

flake.nix:
	$(NIX) flake init

.PHONY: flake.lock
