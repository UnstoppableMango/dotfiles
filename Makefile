NIX ?= nix

build: result

format fmt:
	$(NIX) fmt

check:
	$(NIX) flake check

result:
	$(NIX) build

flake.lock: flake.nix
	$(NIX) flake update
	@touch $@

flake.nix:
	$(NIX) flake init
