HOSTNAME=$(shell hostname)

V01 = filipe@vessel-01.local
V02 = filipe@vessel-02.local

default: update

.PHONY: rebuild
rebuild:
	@echo "Rebuilding $(HOSTNAME)..."
	sudo nixos-rebuild switch --flake .#$(HOSTNAME)

.PHONY: build
build:
	@echo "Building $(HOSTNAME)..."
	nix build .#nixosConfigurations.$(HOSTNAME).config.system.build.toplevel

.PHONY: deploy-vessel-01
deploy-vessel-01:
	@echo "Deploying to vessel-01 (switch)..."
	nixos-rebuild switch --flake .#vessel-01 \
		--target-host $(V01) --build-host $(V01) --sudo

.PHONY: deploy-vessel-02
deploy-vessel-02:
	@echo "Deploying to vessel-02 (boot)..."
	nixos-rebuild boot --flake .#vessel-02 \
		--target-host $(V02) --build-host $(V02) --sudo

.PHONY: reboot-vessel-02
reboot-vessel-02:
	@PENDING=$$(ssh $(V02) "readlink -f /nix/var/nix/profiles/system"); \
	echo "Pending generation: $$PENDING"; \
	echo "Rebooting vessel-02..."; \
	ssh $(V02) "sudo systemctl reboot" 2>/dev/null || true; \
	echo "Waiting for vessel-02 to come back..."; \
	sleep 10; \
	for i in $$(seq 1 30); do \
		ssh -o ConnectTimeout=5 $(V02) "echo ok" 2>/dev/null && break; \
		echo "  waiting... ($$i/30)"; sleep 5; \
	done; \
	echo "vessel-02 is back!"; \
	ACTIVE=$$(ssh $(V02) "readlink /run/current-system"); \
	if [ "$$PENDING" = "$$ACTIVE" ]; then \
		echo "✓ Boot successful: $$ACTIVE"; \
	else \
		echo "⚠  Booted into unexpected generation"; \
		echo "  Expected: $$PENDING"; \
		echo "  Active:   $$ACTIVE"; \
	fi

.PHONY: deploy-vessel-02-reboot
deploy-vessel-02-reboot: deploy-vessel-02 reboot-vessel-02

.PHONY: deploy-all
deploy-all: deploy-vessel-01 deploy-vessel-02

.PHONY: update
update:
	nix flake update

.PHONY: clean
clean:
	nix-collect-garbage -d
