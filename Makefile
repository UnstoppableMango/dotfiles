SRC != find -path '*.nix' -printf '%P\n'

HOST ?= $(shell hostname -s)

ifeq ($(shell uname -s),Darwin)
HOME_CONFIG ?= generic@aarch64-darwin
else ifeq (${HOST},darter)
HOME_CONFIG ?= erik@darter
else ifeq (${HOST},hades)
HOME_CONFIG ?= ${USER}@hades
else
HOME_CONFIG ?= erik@server
endif

build:
	home-manager build --flake ${CURDIR}#${HOME_CONFIG}

container:
	nix build .#container

check:
	nix flake check

watch:
	watchexec -e nix nix flake check

update: flake.lock

home:
	home-manager switch --flake ${CURDIR}#${HOME_CONFIG} -b hm-backup

system:
	sudo nix flake update --flake /etc/nixos
	sudo nixos-rebuild switch --flake /etc/nixos

format fmt:
	nix fmt

.PHONY: flake.lock
flake.lock: ${SRC}
	nix flake update

flake.nix:
	nix flake init

p10k: # This doesn't actually work in make, but it's copy-pastable
	POWERLEVEL9K_CONFIG_FILE=${CURDIR}/modules/zsh/.p10k.zsh p10k configure

.PHONY: build check watch update home system format fmt p10k
