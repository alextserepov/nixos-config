{
  description = "Alex's NixOS + Home Manager config";

  inputs = {
    nixpkgs.url="github:NixOS/nixpkgs/nixos-25.11";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    pkcs11-proxy.url = "github:tiiuae/pkcs11-proxy";
    pkcs11-proxy.flake = false;
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, nixos-hardware, ...}@inputs:
    let
      mkHost = { hostname, system ? "x86_64-linux", username ? "alextserepov" }:
        nixpkgs.lib.nixosSystem {
          inherit system;
          modules =
            let
              hw = ./hosts/${hostname}/hardware-configuration.nix;
            in [
            ./modules/nixos/base.nix
            ./hosts/${hostname}/configuration.nix
            ]
            ++ nixpkgs.lib.optionals (builtins.pathExists hw) [ hw ]
            ++ [
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
        overlayPkcs11ProxyTii = final: prev: {
          pkcs11-proxy-tii = prev.stdenv.mkDerivation {
            pname = "pkcs11-proxy";
            version = "tiiuae-main";

            src = inputs.pkcs11-proxy;

            nativeBuildInputs = with prev; [ cmake pkg-config ];
            buildInputs = with prev; [ openssl ];

            cmakeFlags = [];

            doCheck = false;

            meta = with prev.lib; {
              description = "TIIUAE fork of pkcs11-proxy";
              homepage = "https://github.com/tiiuae/pkcs11-proxy";
              platforms = platforms.linux;
            };
          };
        };
    in
    {
      nixosConfigurations = {
        work = mkHost { hostname = "work"; };
        cpx62 = mkHost { hostname = "cpx62"; system = "x86_64-linux"; };
        arm-builder = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          modules = [
            inputs.disko.nixosModules.disko
            ./hosts/arm-builder/disko.nix
            ./modules/nixos/base.nix
            ./hosts/arm-builder/configuration.nix
            { nixpkgs.config.allowUnfree = true; }
          ];
        };
        rpi-hsm = nixpkgs.lib.nixosSystem {
          system = "aarch64-linux";
          specialArgs = { inherit inputs; };
          modules = [
            ({ ... }: { nixpkgs.overlays = [ overlayPkcs11ProxyTii ]; })
            nixos-hardware.nixosModules.raspberry-pi-4
            "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
            ./hosts/rpi-hsm/configuration.nix
          ];
        };
      };
    };
}
