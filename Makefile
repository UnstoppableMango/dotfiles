SRC != find -path '*.nix' -printf '%P\n'

# Matches how home-manager resolves a configuration implicitly.
USER ?= $(shell id -un)
# `$(shell ...)` rather than `!=`: macOS ships GNU Make 3.81, which predates
# the `!=` shell assignment and would silently leave this empty.
HOST ?= $(shell hostname -s)
HOME_CONFIG ?= ${USER}@${HOST}

build:
	home-manager build --flake ${CURDIR}#${HOME_CONFIG}

check:
	nix flake check

watch:
	watchexec -e nix nix flake check

update: flake.lock

home:
	nix flake update --flake ${HOME}/.config/home-manager
	home-manager switch --flake ${HOME}/.config/home-manager -b hm-backup

system:
	sudo nix flake update --flake /etc/nixos
	sudo nixos-rebuild switch --flake /etc/nixos

format fmt:
	nix fmt

flake.lock: ${SRC}
	nix flake update

flake.nix:
	nix flake init

p10k: # This doesn't actually work in make, but its copy-pastable
	POWERLEVEL9K_CONFIG_FILE=${CURDIR}/modules/zsh/prezto/.p10k.zsh p10k configure

.PHONY: flake.lock
