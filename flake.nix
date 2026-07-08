{
  description = "My NixOS Config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
    let
    lib = nixpkgs.lib;

  nixpkgsConfig = {
    allowUnfree = true;
    permittedInsecurePackages = [
      "electron-39.8.10"
        "pnpm-10.29.2"
    ];
  };

  linuxSystem = "x86_64-linux";
  pkgsLinux = import nixpkgs {
    system = linuxSystem;
    config = nixpkgsConfig;
  };

  macSystem = "aarch64-darwin";
  pkgsMac = import nixpkgs {
    system = macSystem;
    config = nixpkgsConfig;
  };
  in {
    homeConfigurations = {
      helm = home-manager.lib.homeManagerConfiguration {
        pkgs = pkgsLinux;
        modules = [ hosts/helm/home.nix ];
      };
      anchor-01 = home-manager.lib.homeManagerConfiguration {
        pkgs = pkgsLinux;
        modules = [ hosts/anchor-01/home.nix ];
      };
      macbook = home-manager.lib.homeManagerConfiguration {
        pkgs = pkgsMac;
        modules = [ ./hosts/macbook/home.nix ];
      };
    };

    nixosConfigurations = {
      vessel-01 = nixpkgs.lib.nixosSystem {
        system = linuxSystem;
        pkgs = pkgsLinux;
        modules = [
          ./hosts/vessel-01/configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.filipe = import ./hosts/vessel-01/home.nix;
            }
        ];
      };
      vessel-02 = nixpkgs.lib.nixosSystem {
        system = linuxSystem;
        pkgs = pkgsLinux;
        modules = [
          ./hosts/vessel-02/configuration.nix
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.users.filipe = import ./hosts/vessel-02/home.nix;
            }
        ];
      };
    };
  };
}
