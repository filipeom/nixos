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
make              # nix flake update

make rebuild      # local nixos-rebuild switch
make build        # nix build (verify without deploying)

make deploy-vessel-01         # deploy → vessel-01 (switch)
make deploy-vessel-02         # deploy → vessel-02 (boot)
make deploy-vessel-02-reboot  # deploy → vessel-02 (boot + reboot + verify)
make deploy-all               # deploy → both remotes

make reboot-vessel-02  # reboot vessel-02 and verify boot generation

make clean        # nix-collect-garbage -d
```

`deploy-vessel-02` uses `boot` (not `switch`) — the new config is set as the
next boot entry but doesn't replace the running system. Reboot to activate.

Use `deploy-vessel-02-reboot` to deploy, reboot, wait for the server to come
back, and verify the new generation is active — all in one step.

## Links

- [NixOS packages]
- [Home Manager options]

[NixOS packages]: https://search.nixos.org/packages
[Home Manager options]: https://home-manager-options.extranix.com/
