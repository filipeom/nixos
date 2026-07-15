HOSTNAME=$(shell hostname)

default: update

.PHONY: rebuild
rebuild:
	@echo "Updating $(HOSTNAME)..."
	sudo nixos-rebuild switch --flake .#$(HOSTNAME)

.PHONY: update
update:
	nix flake update

.PHONY: clean
clean:
	nix-collect-garbage -d
