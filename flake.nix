{
  description = "Alex's NixOS + Home Manager config";

  inputs = {
    nixpkgs.url="github:NixOS/nixpkgs/nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ...}:
    let
      mkHost = { hostname, system ? "x86_64-linux", username ? "alextserepov" }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            ./modules/nixos/base.nix
            ./hosts/${hostname}/hardware-configuration.nix
            ./hosts/${hostname}/configuration.nix

            {
              nixpkgs.config = {
                allowUnfree = true;
              };
            }
            
            home-manager.nixosModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;

              home-manager.users.${username} = {
                imports = [
                  ./home/home.nix
                ];
              };
            }
          ];
        };
    in
    {
      nixosConfigurations = {
        work = mkHost { hostname = "work"; };
        cpx62 = mkHost { hostname = "cpx62"; system = "x86_64-linux"; };
      };
    };
}
