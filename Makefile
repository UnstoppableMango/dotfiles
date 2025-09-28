NIX ?= nix

SRC != find -path '*.nix' -printf '%P\n'

build: result
update: flake.lock

format fmt:
	$(NIX) fmt

check:
	$(NIX) flake check

result: ${SRC}
	$(NIX) build

flake.lock: ${SRC}
	$(NIX) flake update
	@touch $@

flake.nix:
	$(NIX) flake init
