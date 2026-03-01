{
  description = "My home manaer config";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-25.11";

    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
    let
      lib = nixpkgs.lib;
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in {
      homeConfigurations = {
        helm = home-manager.lib.homeManagerConfiguration {
          inherit pkgs;
          modules = [ hosts/helm/home.nix ];
        };
      };

      nixosConfigurations = {
        vessel-01 = nixpkgs.lib.nixosSystem {
          inherit system;
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
      };
    };
}
