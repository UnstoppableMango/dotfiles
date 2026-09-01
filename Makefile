SRC != find -path '*.nix' -printf '%P\n'

# Matches how home-manager resolves a configuration implicitly.
USER ?= $(shell id -un)
# Absolute path: darwin-rebuild only exists inside an activated nix-darwin
# system, and it is not on PATH under `sudo` on a fresh login shell.
# Use `make darwin-bootstrap` for the first activation, when it exists nowhere.
DARWINREBUILD ?= /run/current-system/sw/bin/darwin-rebuild
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

# `#` opens a comment in a variable assignment but not in a recipe, so the
# flake attribute path is spelled out in each recipe rather than hoisted.
darwin-build:
	nix build ${CURDIR}#darwinConfigurations.${HOST}.system --no-link

# The only step here that needs a sudo window. Build first so the window is
# spent on activation instead of on evaluating and downloading.
darwin: darwin-build
	sudo ${DARWINREBUILD} switch --flake ${CURDIR}#${HOST}

# First activation, before ${DARWINREBUILD} is on PATH. Everything up to the
# last line runs unprivileged, so the sudo window only covers activation.
darwin-bootstrap: darwin-build
	sudo "$$(nix build --no-link --print-out-paths \
		${CURDIR}#darwinConfigurations.${HOST}.config.system.build.darwin-rebuild \
	)/bin/darwin-rebuild" switch --flake ${CURDIR}#${HOST}

format fmt:
	nix fmt

flake.lock: ${SRC}
	nix flake update

flake.nix:
	nix flake init

p10k: # This doesn't actually work in make, but its copy-pastable
	POWERLEVEL9K_CONFIG_FILE=${CURDIR}/shells/zsh/.p10k.zsh p10k configure

.PHONY: flake.lock darwin darwin-build darwin-bootstrap
