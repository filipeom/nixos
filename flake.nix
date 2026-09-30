{
  description = "My NixOS Config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-26.05";

    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lidctl.url = "github:filipeom/lidctl";
  };

  outputs = { nixpkgs, home-manager, lidctl, ... }:
    let
      lib = nixpkgs.lib;
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config = {
          allowUnfree = true;
          permittedInsecurePackages = [
            "electron-41.10.7"
          ];
        };
      };
    in {
      packages.x86_64-linux = {
        lidctl = lidctl.packages.${system}.default;
      };

      homeConfigurations = {
        cflinux = home-manager.lib.homeManagerConfiguration {
	  inherit pkgs;
          modules = [ hosts/cflinux/home.nix ];
        };

      };

      nixosConfigurations = {
        helm = nixpkgs.lib.nixosSystem {
          inherit system;
          inherit pkgs;
          modules = [
            ./hosts/helm/configuration.nix
              home-manager.nixosModules.home-manager
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.users.filipe = {
                  imports = [
                    ./hosts/helm/home.nix
                    lidctl.homeManagerModules.default
                  ];
                };
              }
          ];
        };
        anchor-01 = nixpkgs.lib.nixosSystem {
          inherit system;
          inherit pkgs;
          modules = [
            ./hosts/anchor-01/configuration.nix
              home-manager.nixosModules.home-manager
              {
                home-manager.useGlobalPkgs = true;
                home-manager.useUserPackages = true;
                home-manager.users.filipe = import ./hosts/anchor-01/home.nix;
              }
          ];
        };
        vessel-01 = nixpkgs.lib.nixosSystem {
          inherit system;
          inherit pkgs;
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
          inherit system;
          inherit pkgs;
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
