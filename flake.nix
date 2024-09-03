{
  nixConfig = {
    extra-substituters = [
      # Community cache
      "https://nix-community.cachix.org"
      # Own cache
      #"https://s3.holypenguin.net/nix-cache/"
    ];
  };
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-23.05";

    snowfall-lib = {
      url = "github:snowfallorg/lib/dev";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    flake = {
      url = "github:snowfallorg/flake?ref=v1.3.1";
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
      url = "github:nix-community/lanzaboote/v0.4.1";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";

    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    fw-fanctrl = {
      #url = "github:Svenum/fw-fanctrl/update-service";
      url = "github:TamtamHero/fw-fanctrl/packaging/nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    raspberry-pi-nix.url = "github:nix-community/raspberry-pi-nix";

    sops-nix.url = "github:Mic92/sops-nix";
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
    
    overlays = with inputs; [
      flake.overlays.default
    ];

    systems.modules.nixos = with inputs; [
      solaar.nixosModules.default
      home-manager.nixosModules.home-manager
      sops-nix.nixosModules.sops
    ];

    systems.hosts.srv-raspi.modules = with inputs; [
      nixos-hardware.nixosModules.raspberry-pi-5
      raspberry-pi-nix.nixosModules.raspberry-pi
    ];

    systems.hosts.Yon.modules = with inputs; [
      nixos-hardware.nixosModules.framework-16-7040-amd
      fw-fanctrl.nixosModules.default
    ];
  };
}
