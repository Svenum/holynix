{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-25.05";

    snowfall-lib = {
      url = "github:anntnzrb/snowfall-lib";
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

    nixvim.url = "github:nix-community/nixvim";

    auto-cpufreq = {
      url = "github:AdnanHodzic/auto-cpufreq";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixVirt = {
      url = "github:AshleyYakeley/NixVirt";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lanzaboote = {
      url = "github:nix-community/lanzaboote/v1.0.0";
      inputs = {
        nixpkgs.follows = "nixpkgs";
      };
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    nixos-raspberrypi.url = "github:nvmd/nixos-raspberrypi/main";

    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    catppuccin.url = "github:catppuccin/nix";

    nix-flatpak.url = "github:gmodena/nix-flatpak";

    authentik = {
      url = "github:nix-community/authentik-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    inputs:
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
        cudaSupport = true;
      };

      systems = {
        modules.nixos = with inputs; [
          solaar.nixosModules.default
          home-manager.nixosModules.home-manager
          sops-nix.nixosModules.sops
          catppuccin.nixosModules.catppuccin
        ];

        hosts = {
          srv-raspi5 = {
            modules = with inputs; [
              nixos-hardware.nixosModules.raspberry-pi-5
              nixos-raspberrypi.nixosModules.raspberry-pi-5.base
              nixos-raspberrypi.nixosModules.raspberry-pi-5.page-size-16k
            ];
            specialArgs = {
              inherit (inputs) nixos-raspberrypi;
            };
          };

          Yon.modules = with inputs; [
            nixos-hardware.nixosModules.framework-16-7040-amd
          ];

          kaeru.modules = with inputs; [
            authentik.nixosModules.default
          ];
        };
      };

      homes.modules = with inputs; [
        plasma-manager.homeModules.plasma-manager
        catppuccin.homeModules.catppuccin
        nixvim.homeModules.nixvim
      ];

    };
}
