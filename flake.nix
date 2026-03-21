{
  description = "My home manaer config";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
    let
      lib = nixpkgs.lib;
      system = "x86_64-linux";
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
    in {
      homeConfigurations = {
        helm = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ hosts/helm/home.nix ];
        };
        anchor-01 = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ hosts/anchor-01/home.nix ];
        };
      };

      nixosConfigurations = {
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
