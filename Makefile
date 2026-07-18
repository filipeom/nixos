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

.PHONY: reboot-vessel-01
reboot-vessel-01:
	./scripts/reboot-host.sh $(V01)

.PHONY: reboot-vessel-02
reboot-vessel-02:
	./scripts/reboot-host.sh $(V02)

.PHONY: deploy-vessel-01-reboot
deploy-vessel-01-reboot: deploy-vessel-01 reboot-vessel-01

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
