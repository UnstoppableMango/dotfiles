NIX       ?= nix
WATCHEXEC ?= watchexec

SRC != find -path '*.nix' -printf '%P\n'

check:
	$(NIX) flake check

build:
	$(NIX) build .#homeConfigurations.erik

watch:
	$(WATCHEXEC) -e nix $(NIX) flake check

update: flake.lock

system:
	sudo nix flake update --flake /etc/nixos
	sudo nixos-rebuild switch --flake /etc/nixos

format fmt:
	$(NIX) fmt

.PHONY: flake.lock
flake.lock: ${SRC}
	$(NIX) flake update

flake.nix:
	$(NIX) flake init
