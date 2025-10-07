{ config, lib, pkgs, ... }:

with lib;
with lib.types;
let
  cfg = config.holynix.virtualisation.podman;
in
{
  options.holynix.virtualisation.podman = {
    enable = mkOption {
      default = false;
      type = bool;
      description = "Enable podman and install needed tools";
    };
    disableAutoStart = mkOption {
      default = false;
      type = bool;
      description = "If podman autostart should be disabled";
    };
  };

  config = mkIf cfg.enable {
    virtualisation = {
      # Enable common container config files in /etc/containers
      containers.enable = true;
      podman = {
        enable = true;

        # Create a `docker` alias for podman, to use it as a drop-in replacement
        dockerCompat = true;

        # Required for containers under podman-compose to be able to talk to each other.
        defaultNetwork.settings.dns_enabled = true;
      };
    };

    systemd = {
      services.podman.wantedBy = mkIf cfg.disableAutoStart (mkForce [ ]);
      sockets.podman.wantedBy = mkIf cfg.disableAutoStart (mkForce [ ]);
      user = {
        services.podman.wantedBy = mkIf cfg.disableAutoStart (mkForce [ ]);
        sockets.podman.wantedBy = mkIf cfg.disableAutoStart (mkForce [ ]);
      };
    };
    # Compose
    environment = {
      shellAliases = {
        compose = "podman-compose";
      };

      # Useful other development tools
      systemPackages = with pkgs; [
        podman-tui # status of containers in the terminal
        podman-compose # start group of containers for dev
      ];
    };
  };
}
