# nixos

Personal NixOS flake for all machines.

## Machines

| Host | Role | Type |
|------|------|------|
| `helm` | Laptop/workstation | NixOS + home-manager |
| `vessel-01` | Desktop / dev compute (Hyprland, Ollama) | NixOS + home-manager |
| `vessel-02` | Edge + server (nginx/TLS, DNS, WireGuard, CI, Minecraft) | NixOS + home-manager |
| `anchor-01` | Core data server (Nextcloud, Plex) | NixOS + home-manager |
| `cflinux` | Work machine | home-manager only |

Architecture and hardware are documented in [`doc/`](doc/README.md):
[ADR-001](doc/ADR-001.md) (architecture), [INV-001](doc/INV-001.md) (inventory),
[FS-001](doc/FS-001.md) (anchor-01 migration), and runbooks
([RUN-001](doc/RUN-001.md), [RUN-002](doc/RUN-002.md)).

## Structure

```
flake.nix                          # flake entry point
hosts/
  helm/          configuration.nix, home.nix, ...
  vessel-01/     configuration.nix, home.nix, ...
  vessel-02/     configuration.nix, home.nix, ...
  anchor-01/     configuration.nix, home.nix, ...
  cflinux/       home.nix (home-manager only)
modules/
  programs/      git, zsh, neovim, kitty, tmux, wakeonlan
  services/      hyprland, waybar, minecraft-atm10, minecraft-bmc4, power-tune
dotfiles/
```

## Makefile

```sh
make                         # nix flake update
make rebuild                 # local nixos-rebuild switch
make build                   # nix build (verify without deploying)
make check                   # SSH + current generation check on the vessels

# remote deploy (direct LAN, <host>.local)
make deploy-vessel-01        # deploy → vessel-01 (switch)
make deploy-vessel-02        # deploy → vessel-02 (switch)
make deploy-all              # deploy → both remotes

# deploy + reboot + verify the new generation is active
make deploy-vessel-01-reboot
make deploy-vessel-02-reboot

# reboot only
make reboot-vessel-01        # reboot vessel-01 and verify boot generation
make reboot-vessel-02        # reboot vessel-02 and verify boot generation

make clean                   # nix-collect-garbage -d
```

Remote targets reach the hosts directly over the LAN (`vessel-01.local`,
`vessel-02.local`); no jump host is needed. The `*-reboot` targets deploy,
reboot, wait for the host to come back, and verify the new generation is active
— all in one step.

`scripts/reboot-host.sh <ssh-host>` is the underlying reboot+verify script,
callable directly for any host.

## Links

- [NixOS packages]
- [Home Manager options]

[NixOS packages]: https://search.nixos.org/packages
[Home Manager options]: https://home-manager-options.extranix.com/
