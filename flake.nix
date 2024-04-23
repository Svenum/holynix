{
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    snowfall-lib = {
        url = "github:snowfallorg/lib";
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

    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
  };

  outputs = inputs: inputs.snowfall-lib.mkFlake {
    inherit inputs;
    src = ./.;

    systems.modules.nixos = with inputs; [
      solaar.nixosModules.default
      nixVirt.nixosModules.default
      home-manager.nixosModules.home-manager
    ];

    systems.hosts.Yon.modules = with inputs; [
      lanzaboote.nixosModules.lanzaboote
      nixos-hardware.nixosModules.framework-16-7040-amd
    ];

    snowfall = {
      namespace = "holynix";
      meta = {
        name = "holynix";
        title = "Holy Nix";
      };
    };
  };
}
