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
    nix = {
      # Garbage collection
      gc = {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 1w";
      };
      settings.auto-optimise-store = true;

      package = pkgs.nixVersions.latest;

      # Add sources
      settings = {
        substituters = [
          # nix community's cache server
          "https://nix-community.cachix.org"

          # own cache
          "https://iglu.holypenguin.net/default"

        ];
        trusted-substituters = [
          # nix community's cache server
          "https://nix-community.cachix.org"

          # own cache
          "https://iglu.holypenguin.net/default"
        ];
        trusted-public-keys = [
          # nix community's cache server public key
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="

          # own cache
          "default:N70oHEuy1jSzIZ5xEZdqCv4/49KERecq/P3sleSLxjI="
        ];

        # Configure Nix
        experimental-features = [ "nix-command" "flakes" ];
      };
    };

    system.stateVersion = "24.05";
  };
}
