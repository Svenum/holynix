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
        "https://cache.nixos.org"

        # nix community's cache server
        "https://nix-community.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="

        # nix community's cache server public key
        "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      ];
    }
  };
}
