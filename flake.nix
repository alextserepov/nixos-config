{
  description = "Alex's NixOS + Home Manager config";

  inputs = {
    nixpkgs.url="github:NixOS/nixpkgs/nixos-25.11";
    home-manager.url = "github:nix-community/home-manager/release-25.11";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, ...}:
  let
    system = "x86_64-linux";
    in  {
      nixosConfigurations.work = nixpkgs.lib.nixosSystem {
        inherit system;
	modules = [
	  ./nixos/hardware-configuration.nix
	  ./nixos/configuration.nix

          home-manager.nixosModules.home-manager
	  {
	    home-manager.useGlobalPkgs = true;
	    home-manager.useUserPackages = true;
	    home-manager.users.alextserepov = import ./home/home.nix;
	  }
	];
      };
    };
}