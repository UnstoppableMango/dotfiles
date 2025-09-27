NIX       ?= nix
WATCHEXEC ?= watchexec

SRC != find -path '*.nix' -printf '%P\n'

build:
	$(NIX) build .#nixosConfigurations.hades.config.system.build.toplevel

check:
	$(NIX) flake check

watch:
	$(WATCHEXEC) -e nix $(NIX) flake check

update: flake.lock

format fmt:
	$(NIX) fmt

flake.lock: ${SRC}
	$(NIX) flake update
	@touch $@

flake.nix:
	$(NIX) flake init
