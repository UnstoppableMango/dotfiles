NIX ?= nix

build:
	$(NIX) build

check:
	$(NIX) flake check

flake.lock: flake.nix
	$(NIX) flake update
	@touch $@

flake.nix:
	$(NIX) flake init
