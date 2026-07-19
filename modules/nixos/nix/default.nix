{
  config,
  lib,
  pkgs,
  ...
}:

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

          # catppuccin
          "https://catppuccin.cachix.org"

          # jellyfin
          "https://cache.flox.dev"

          # cuda
          "https://cache.nixos-cuda.org"
        ];
        trusted-substituters = [
          # nix community's cache server
          "https://nix-community.cachix.org"

          # catppuccin
          "https://catppuccin.cachix.org"

          # jellyfin
          "https://cache.flox.dev"

          # cuda
          "https://cache.nixos-cuda.org"
        ];
        trusted-public-keys = [
          # nix community's cache server public key
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="

          # catppuccin
          "catppuccin.cachix.org-1:noG/4HkbhJb+lUAdKrph6LaozJvAeEEZj4N732IysmU="

          # jellyfin
          "flox-cache-public-1:7F4OyH7ZCnFhcze3fJdfyXYLQw/aV7GEed86nQ7IsOs="

          # cuda
          "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
        ];

        # Configure Nix
        experimental-features = [
          "nix-command"
          "flakes"
        ];
      };
    };

    system.stateVersion = "26.11";
  };
}
