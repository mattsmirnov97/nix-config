{
  description = "NixOS setup for development (Parallels‑ready, latest kernel, Pixie‑friendly)";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nurpkgs.url = "github:nix-community/NUR";

    nix-index-database.url = "github:Mic92/nix-index-database";
    nix-index-database.inputs.nixpkgs.follows = "nixpkgs";

    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    nixvim = {
      url = "github:nix-community/nixvim";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ { self, nixpkgs, home-manager, darwin, nix-index-database, nixvim, ... }:
  let
    userDetails = {
      fullName = "Matvey Smirnov";
      userName = "matt";
    };

    desktopDetails = { dpi = 192; };              # Retina friendly
    homeManagerStateVersion = "24.05";

    # single authoritative kernel declaration (latest)
    perfTuning = { pkgs, lib, ... }: {
      nixpkgs.config.allowUnfree = true;           # Parallels tools
      boot.kernelPackages = lib.mkForce pkgs.linuxPackages_latest;
      boot.kernel.sysctl."kernel.unprivileged_bpf_disabled" = 1;
    };
  in {
    #──────────────────────── NixOS configs ──────────────────────────#
    nixosConfigurations = {
      workstation = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs userDetails; };
        modules = [
          perfTuning
          ./machines/workstation
          ./system/nixos/default.nix
          ({ ... }: {
            machine.role = "pc";
            machine.virtualization.enable = true;
            machine.x11 = { enable = true; dpi = 144; };
            machine.wayland = { enable = true; scale = 1.0; };
          })
          ./system/nixos/virtualization.nix
          nix-index-database.nixosModules.nix-index
          home-manager.nixosModules.home-manager
          ./home
        ];
      };

      prl-dev = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";                 # change to x86_64 for Intel VM
        specialArgs = { inherit inputs userDetails desktopDetails; };
        modules = [
          perfTuning
          ./machines/prl-dev
          ./system/nixos/default.nix
          ({ pkgs, ... }: {
            hardware.parallels.enable = true;
            machine.role = "pc";
            machine.x11 = { enable = true; dpi = desktopDetails.dpi; };
            machine.wayland.enable = true;
            boot.kernel.sysctl."vm.max_map_count" = 1048576;  # Pixie / ES
          })
          nix-index-database.nixosModules.nix-index
          home-manager.nixosModules.home-manager
          ./home
        ];
      };

      utm-dev = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        specialArgs = { inherit inputs userDetails desktopDetails; };
        modules = [
          perfTuning
          ./machines/utm-dev
          ./system/nixos/default.nix
          ({ ... }: {
            machine.role = "pc";
            machine.x11 = { enable = true; dpi = 96; };
            machine.wayland.enable = true;
          })
          nix-index-database.nixosModules.nix-index
          home-manager.nixosModules.home-manager
          ./home
        ];
      };

      hp-mgmt = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs userDetails; };
        modules = [
          perfTuning
          ./machines/hp-mgmt
          ./system/nixos/default.nix
          ({ ... }: {
            machine.role = "pc";
            machine.x11 = { enable = true; dpi = 96; };
            machine.wayland.enable = true;
          })
          nix-index-database.nixosModules.nix-index
          home-manager.nixosModules.home-manager
          ./home
        ];
      };

      maui = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [ perfTuning ./machines/maui ];
      };
    };

    #──────────────────────── macOS configs ──────────────────────────#
    darwinConfigurations = {
      A2130862 = darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = { inherit (nixpkgs) lib; inherit inputs nixpkgs; };
        modules = [
          ./system/macos
          home-manager.darwinModules.home-manager
          ({ ... }: {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              users.${userDetails.userName} = {
                home = {
                  username      = userDetails.userName;
                  homeDirectory = "/Users/${userDetails.userName}";
                  stateVersion  = homeManagerStateVersion;
                };
                programs.home-manager.enable = true;
                imports = [ ./home/macos/neovim.nix ];
              };
            };
          })
        ];
      };
    };
  };
}
