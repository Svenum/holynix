{ options, config, lib, pkgs, ... }:

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
    # Enable common container config files in /etc/containers
    virtualisation.containers.enable = true;
    virtualisation = {
      podman = {
        enable = true;

        # Create a `docker` alias for podman, to use it as a drop-in replacement
        dockerCompat = true;

        # Required for containers under podman-compose to be able to talk to each other.
        defaultNetwork.settings.dns_enabled = true;
      };
    };

    systemd.services.podman.wantedBy = mkIf cfg.disableAutoStart (mkForce []);
    systemd.user.services.podman.wantedBy = mkIf cfg.disableAutoStart (mkForce []);
    systemd.sockets.podman.wantedBy = mkIf cfg.disableAutoStart (mkForce []);
    systemd.user.sockets.podman.wantedBy = mkIf cfg.disableAutoStart (mkForce []);
    # Compose
    environment.shellAliases = {
      compose = "podman-compose";
    };

    # Useful other development tools
    environment.systemPackages = with pkgs; [
      podman-tui # status of containers in the terminal
      podman-compose # start group of containers for dev
    ];
  };
}
