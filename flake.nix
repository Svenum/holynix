{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.05";

    nur = {
      url = "github:nix-community/NUR";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    snowfall-lib = {
      url = "github:snowfallorg/lib/dev";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    plasma-manager = {
      url = "github:nix-community/plasma-manager";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };

    solaar = {
      url = "github:Svenum/Solaar-Flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    auto-cpufreq = {
      url = "github:AdnanHodzic/auto-cpufreq";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixVirt = {
      url = "github:AshleyYakeley/NixVirt";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.2";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    raspberry-pi-nix.url = "github:nix-community/raspberry-pi-nix/v0.4.1";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    catppuccin = {
      url = "github:catppuccin/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    musnix = {
      url = "github:musnix/musnix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-flatpak.url = "github:gmodena/nix-flatpak";
  };

  outputs = inputs:
    let
      lib = inputs.snowfall-lib.mkLib {
        inherit inputs;
        src = ./.;
        snowfall = {
          namespace = "holynix";
          meta = {
            name = "holynix";
            title = "Holy Nix";
          };
        };
      };
    in
    lib.mkFlake {
      channels-config = {
        allowUnfree = true;
        nvidia.acceptLicense = true;
      };

      systems = {
        modules.nixos = with inputs; [
          solaar.nixosModules.default
          home-manager.nixosModules.home-manager
          sops-nix.nixosModules.sops
          nur.modules.nixos.default
          catppuccin.nixosModules.catppuccin
          musnix.nixosModules.musnix
        ];

        hosts = {
          srv-raspi5.modules = with inputs; [
            nixos-hardware.nixosModules.raspberry-pi-5
            raspberry-pi-nix.nixosModules.raspberry-pi
          ];

          srv-oracle.modules = with inputs; [
            nixos-generators.nixosModules.qcow-efi
          ];

          Yon = {
            modules = with inputs; [
              nixos-hardware.nixosModules.framework-16-7040-amd
            ];

            specialArgs = {
              inherit (inputs) nur;
            };
          };
        };
      };

      homes.modules = with inputs; [
        plasma-manager.homeModules.plasma-manager
        catppuccin.homeModules.catppuccin
      ];

    };
}
