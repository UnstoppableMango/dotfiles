SRC != find -path '*.nix' -printf '%P\n'

build:
	home-manager build --flake ${CURDIR}

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

graph: docs/dependency-graph.md

docs/dependency-graph.md: ${SRC} flake.nix scripts/dep-graph.nix
	nix eval --impure --raw --file scripts/dep-graph.nix > $@

p10k: # This doesn't actually work in make, but its copy-pastable
	POWERLEVEL9K_CONFIG_FILE=${CURDIR}/shells/zsh/.p10k.zsh p10k configure

.PHONY: flake.lock graph
