{ options, config, lib, pkgs, ... }:

with lib;
with lib.types;
let
  cfg = config.holynix.nix;
in
{
  options.holynix.nix = {
   enable = mkOption {
      type = bool;
      default = true;
    };
  };

  config = mkIf cfg.enable {
    # Garbage collection
    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 1w";
    };
    nix.settings.auto-optimise-store = true;

    nix.package = pkgs.nixVersions.git;

    # Configure Nix
    nix.settings.experimental-features = [ "nix-command" "flakes" ];
    system.stateVersion = "24.05";

    # Add sources
    nix.settings = {
      substituters = [
        # nix community's cache server
        "https://nix-community.cachix.org"

        # own cache
        "https://attic.holypenguin.net/holynix"

        # Boerg
        "https://cache.boerg.co/boerg"
      ];
      trusted-substituters = [
        # nix community's cache server
        "https://nix-community.cachix.org"

        # own cache
        "https://attic.holypenguin.net/holynix"
        
        # Boerg
        "https://cache.boerg.co/boerg"
      ];
      trusted-public-keys = [
        # nix community's cache server public key
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="

        # own cache
        "holynix:Ucr2JJ5xLEy4hElI/SToX5klNe4I3wKgVIa2+b3lmYo="

        # Boerg
        "boerg:lB5q12LbdsiDdUgG6erYt6WkMHnqeDUiC3WBTFV8Asc="
      ];
    };
  };
}
