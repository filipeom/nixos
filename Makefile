.PHONY: update clean

update:
	home-manager switch --flake .#helm

clean:
	nix-collect-garbage -d
