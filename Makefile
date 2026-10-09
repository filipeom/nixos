HOSTNAME=$(shell hostname)

V01 = filipe@vessel-01.local
V02 = filipe@vessel-02.local

default: update

.PHONY: check
check:
	./scripts/check-host.sh $(V01)
	./scripts/check-host.sh $(V02)

.PHONY: rebuild
rebuild:
	@echo "Rebuilding $(HOSTNAME)..."
	sudo nixos-rebuild switch --flake .#$(HOSTNAME)

.PHONY: build
build:
	@echo "Building $(HOSTNAME)..."
	nix build .#nixosConfigurations.$(HOSTNAME).config.system.build.toplevel

.PHONY: diff
diff: build
	@echo "Package changes vs the running system:"
	nix store diff-closures /run/current-system ./result

.PHONY: update
update:
	nix flake update

.PHONY: clean
clean:
	nix-collect-garbage -d
