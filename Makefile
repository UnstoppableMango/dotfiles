SRC != find -path '*.nix' -printf '%P\n'

# `$(shell ...)` rather than `!=`: macOS ships GNU Make 3.81, which predates
# the `!=` shell assignment and would silently leave this empty.
HOST ?= $(shell hostname -s)
UNAME_S := $(shell uname -s)

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
	home-manager switch --flake ${CURDIR}#${HOME_CONFIG} -b hm-backup

system:
	sudo nix flake update --flake /etc/nixos
	sudo nixos-rebuild switch --flake /etc/nixos

format fmt:
	nix fmt

flake.lock: ${SRC}
	nix flake update

flake.nix:
	nix flake init

p10k: # Does not work under make; run the command by hand.
	POWERLEVEL9K_CONFIG_FILE=${CURDIR}/modules/zsh/.p10k.zsh p10k configure

# `home` is also a directory, so make would otherwise consider it up to date.
.PHONY: build check watch update home system format fmt p10k

.PHONY: flake.lock
