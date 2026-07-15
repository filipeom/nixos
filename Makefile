HOSTNAME=$(shell hostname)

.PHONY: update
update:
	@echo "Updating $(HOSTNAME)..."
	sudo nixos-rebuild switch --flake .#$(HOSTNAME)

.PHONY: clean
clean:
	nix-collect-garbage -d
