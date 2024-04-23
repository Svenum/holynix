{ options, config, lib, ... }:

let
  cfg = config.holynix.nix;
in
{
  options.holynix.nix = {
   enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
    # Garbage collection
    nix.gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 1w";
    };
    nix.settings.auto-optimise-store = true;

    # Configure Nix
    nix.settings.experimental-features = [ "nix-command" "flakes" ];
    system.stateVersion = "24.05";
  };
}
