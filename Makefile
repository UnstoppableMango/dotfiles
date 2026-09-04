SRC != find -path '*.nix' -printf '%P\n'

# `$(shell ...)` rather than `!=`: macOS ships GNU Make 3.81, which predates
# the `!=` shell assignment and would silently leave this empty.
HOST ?= $(shell hostname -s)
UNAME_S := $(shell uname -s)

# The most specific home configuration for the current host: darwin builds
# the identity-free generic config, darter/hades build their own named
# config, and any other Linux box falls back to erik@server.
ifeq (${UNAME_S},Darwin)
HOME_CONFIG ?= generic@aarch64-darwin
else ifeq (${HOST},darter)
HOME_CONFIG ?= erik@darter
else ifeq (${HOST},hades)
HOME_CONFIG ?= erik@hades
else
HOME_CONFIG ?= erik@server
endif

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
