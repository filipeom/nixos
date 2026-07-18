# nixos

Personal NixOS flake for all machines.

## Machines

| Host | Role | Type |
|------|------|------|
| `helm` | Laptop/workstation | NixOS + home-manager |
| `vessel-01` | Development desktop | NixOS + home-manager |
| `vessel-02` | Server (Minecraft, CI runner) | NixOS + home-manager |
| `anchor-01` | Core Server (Nextcloud, Plex) | Ubuntu + home-manager |

## Structure

```
flake.nix                          # flake entry point
hosts/
  helm/          configuration.nix, home.nix, ...
  vessel-01/     configuration.nix, home.nix, ...
  vessel-02/     configuration.nix, home.nix, ...
  anchor-01/     home.nix, ...
modules/
  programs/      git, zsh, neovim, kitty, tmux
  services/      hyprland, waybar, minecraft, ...
dotfiles/
```

## Makefile

```sh
make                         # nix flake update
make rebuild                 # local nixos-rebuild switch
make build                   # nix build (verify without deploying)

# remote deploy
make deploy-vessel-01        # deploy → vessel-01 (switch)
make deploy-vessel-02        # deploy → vessel-02 (boot)
make deploy-vessel-01-reboot # deploy → vessel-01 (switch + reboot + verify)
make deploy-vessel-02-reboot # deploy → vessel-02 (boot + reboot + verify)
make deploy-all              # deploy → both remotes

# reboot only
make reboot-vessel-01        # reboot vessel-01 and verify boot generation
make reboot-vessel-02        # reboot vessel-02 and verify boot generation

make clean                   # nix-collect-garbage -d
```

`deploy-vessel-02` uses `boot` (not `switch`) — the new config is set as the
next boot entry but doesn't replace the running system. Reboot to activate.

The `*-reboot` targets deploy, reboot, wait for the host to come back, and
verify the new generation is active — all in one step.

`scripts/reboot-host.sh <ssh-host>` is the underlying reboot+verify script,
callable directly for any host.

## Links

- [NixOS packages]
- [Home Manager options]

[NixOS packages]: https://search.nixos.org/packages
[Home Manager options]: https://home-manager-options.extranix.com/
