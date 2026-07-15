.PHONY: update clean

update:
	sudo nixos-rebuild switch --flake .#helm

clean:
	nix-collect-garbage -d
