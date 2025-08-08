{
  description = "NixOS setup for development";

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

  outputs = inputs@{ self, nixpkgs, home-manager, darwin, nix-index-database, nixvim, ... }:
  let
    userDetails = {
      fullName = "Matvey Smirnov";     # change if needed
      userName = "matt";
    };

    desktopDetails = { dpi = 192; };     # Retina‑friendly DPI
    homeManagerStateVersion = "24.05";

    perfTuning = { pkgs, ... }: {
      nixpkgs.config.allowUnfree = true;      # required for Parallels Tools
      boot.kernelPackages = pkgs.linuxPackages_latest; # best eBPF perf
      boot.kernel.sysctl."kernel.unprivileged_bpf_disabled" = 1; # safer
    };
  in {
    #───────────────────────── NixOS configurations ─────────────────────────#
    nixosConfigurations = {
      # ---------------------------- Workstation (x86) ----------------------
      workstation = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs userDetails; };
        modules = [
          perfTuning
          ./machines/workstation
          ./system/nixos/default.nix
          ({ ... }: {
            machine = {
              role = "pc";
              virtualization.enable = true;
              x11 = { enable = true; dpi = 144; };
              wayland = { enable = true; scale = 1.0; };
            };
          })
          ./system/nixos/virtualization.nix
          nix-index-database.nixosModules.nix-index
          home-manager.nixosModules.home-manager
          ./home
        ];
      };

      # ---------------------------- Parallels guest ------------------------
      prl-dev = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";                       # Mac M‑series; change to x86_64 if needed
        specialArgs = { inherit inputs userDetails desktopDetails; };
        modules = [
          perfTuning
          ./machines/prl-dev           # create/adjust as necessary
          ./system/nixos/default.nix

          ({ pkgs, ... }: {
            # Parallels Guest Tools for native‑like UX
            hardware.parallels.enable = true;

            machine = {
              role = "pc";
              x11 = { enable = true; dpi = desktopDetails.dpi; }; # HiDPI auto‑resize
              wayland.enable = true;
            };

            # Increase mmap limit (Pixie PEM may need it)
            boot.kernel.sysctl."vm.max_map_count" = 1048576;
          })

          nix-index-database.nixosModules.nix-index
          home-manager.nixosModules.home-manager
          ./home
        ];
      };

      # ---------------------------- UTM (QEMU) -----------------------------
      utm-dev = nixpkgs.lib.nixosSystem {
        system = "aarch64-linux";
        specialArgs = { inherit inputs userDetails desktopDetails; };
        modules = [
          perfTuning
          ./machines/utm-dev
          ./system/nixos/default.nix
          ({ ... }: {
            machine = {
              role = "pc";
              x11 = { enable = true; dpi = 96; };
              wayland.enable = true;
            };
          })
          nix-index-database.nixosModules.nix-index
          home-manager.nixosModules.home-manager
          ./home
        ];
      };

      # ----------------------------- Other hosts ---------------------------
      hp-mgmt = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs userDetails; };
        modules = [ perfTuning ./machines/hp-mgmt ./system/nixos/default.nix
          ({ ... }: { machine.role = "pc"; machine.x11.enable = true; machine.x11.dpi = 96; machine.wayland.enable = true; })
          nix-index-database.nixosModules.nix-index home-manager.nixosModules.home-manager ./home ];
      };

      maui = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = { inherit inputs; };
        modules = [ perfTuning ./machines/maui ];
      };
    };

    #────────────────────────── macOS configurations ───────────────────────#
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
  }
}
