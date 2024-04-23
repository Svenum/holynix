{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixpkgs-stable.url = "github:nixos/nixpkgs/nixos-23.05";

    snowfall-lib = {
      url = "github:snowfallorg/lib/dev";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    plasma-manager = {
      url = "github:pjones/plasma-manager";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        home-manager.follows = "home-manager";
      };
    };

    solaar = {
      url = "github:Svenum/Solaar-Flake/main";
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
      url = "github:nix-community/lanzaboote/v0.3.0";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    #nixos-hardware = {
    #  url = "github:NixOS/nixos-hardware/master";
    #  inputs.nixpkgs.follows = "nixpkgs";
    #};
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
    };

    systems.modules.nixos = with inputs; [
      solaar.nixosModules.default
      nixVirt.nixosModules.default
      home-manager.nixosModules.home-manager
    ];

    systems.hosts.Yon.modules = with inputs; [
      lanzaboote.nixosModules.lanzaboote
      #nixos-hardware.nixosModules.framework-16-7040-amd
    ];

  };
}
