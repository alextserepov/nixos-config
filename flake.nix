{
  description = "Alex's NixOS + Home Manager config";

  inputs = {
    nixpkgs.url="github:NixOS/nixpkgs/nixos-25.11";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    disko.url = "github:nix-community/disko";
    disko.inputs.nixpkgs.follows = "nixpkgs";
    pkcs11-proxy.url = "github:tiiuae/pkcs11-proxy";
    pkcs11-proxy.flake = false;
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
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

            nativeBuildInputs = with prev; [ cmake pkg-config bash coreutils ];
            buildInputs = with prev; [ openssl libseccomp ];

            cmakeFlags = [];

            postPatch = ''
              chmod +x mksyscalls.sh
              substituteInPlace mksyscalls.sh \
                --replace "/usr/bin/env bash" "${prev.bash}/bin/bash" \
                --replace "/usr/bin/env sh" "${prev.bash}/bin/bash"
              patchShebangs mksyscalls.sh
            '';

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
            ./hosts/arm-builder/hardware-configuration.nix
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
            inputs.sops-nix.nixosModules.sops
            nixos-hardware.nixosModules.raspberry-pi-4
            "${nixpkgs}/nixos/modules/installer/sd-card/sd-image-aarch64.nix"
            ./hosts/rpi-hsm/configuration.nix
          ];
        };
      };

      packages = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" ] (system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          baseInputs = [ pkgs.bash pkgs.coreutils pkgs.hcloud pkgs.openssh pkgs.nix ];
          mkScript = { name, path, extraInputs ? [] }: pkgs.writeShellApplication {
            inherit name;
            runtimeInputs = baseInputs ++ extraInputs;
            text = builtins.readFile path;
          };
        in
        {
          arm-builder-up = mkScript { name = "arm-builder-up"; path = ./scripts/hcloud/arm-builder-up.sh; };
          arm-builder-down = mkScript { name = "arm-builder-down"; path = ./scripts/hcloud/arm-builder-down.sh; };
          arm-builder-rescue = mkScript { name = "arm-builder-rescue"; path = ./scripts/hcloud/arm-builder-rescue.sh; };
          arm-builder-install = mkScript { name = "arm-builder-install"; path = ./scripts/hcloud/arm-builder-install.sh; };
          arm-builder-up-install = mkScript {
            name = "arm-builder-up-install";
            path = ./scripts/hcloud/arm-builder-up-install.sh;
            extraInputs = [
              self.packages.${system}.arm-builder-up
              self.packages.${system}.arm-builder-rescue
              self.packages.${system}.arm-builder-install
              self.packages.${system}.arm-builder-trust
            ];
          };
          arm-builder-trust = mkScript { name = "arm-builder-trust"; path = ./scripts/hcloud/arm-builder-trust.sh; };
          arm-builder-deploy = mkScript { name = "arm-builder-deploy"; path = ./scripts/hcloud/arm-builder-deploy.sh; };

          # Alias to match requested command name.
          nix-builder-down = mkScript { name = "nix-builder-down"; path = ./scripts/hcloud/arm-builder-down.sh; };
        }
      );

      apps = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" ] (system: {
        arm-builder-up = {
          type = "app";
          program = "${self.packages.${system}.arm-builder-up}/bin/arm-builder-up";
        };
        arm-builder-down = {
          type = "app";
          program = "${self.packages.${system}.arm-builder-down}/bin/arm-builder-down";
        };
        arm-builder-rescue = {
          type = "app";
          program = "${self.packages.${system}.arm-builder-rescue}/bin/arm-builder-rescue";
        };
        arm-builder-install = {
          type = "app";
          program = "${self.packages.${system}.arm-builder-install}/bin/arm-builder-install";
        };
        arm-builder-up-install = {
          type = "app";
          program = "${self.packages.${system}.arm-builder-up-install}/bin/arm-builder-up-install";
        };
        arm-builder-trust = {
          type = "app";
          program = "${self.packages.${system}.arm-builder-trust}/bin/arm-builder-trust";
        };
        arm-builder-deploy = {
          type = "app";
          program = "${self.packages.${system}.arm-builder-deploy}/bin/arm-builder-deploy";
        };
        nix-builder-down = {
          type = "app";
          program = "${self.packages.${system}.nix-builder-down}/bin/nix-builder-down";
        };
      });
    };
}
