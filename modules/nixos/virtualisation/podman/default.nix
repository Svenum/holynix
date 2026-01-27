{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
with lib.types;
let
  cfg = config.holynix.virtualisation.podman;

  mkNetdevs = attrs: {
    "10-shim-${attrs.name}" = {
      netdevConfig = {
        Kind = "ipvlan";
        Name = "shim-${attrs.name}";
      };
      ipvlanConfig = {
        Mode = "L2";
      };
    };
    "10-br0" = {
      netdevConfig = {
        Kind = "bridge";
        Name = attrs.name;
      };
    };
  };

  mkNetworks = attrs: {
    "30-${attrs.interface}" = {
      matchConfig.Name = attrs.interface;
      networkConfig.Bridge = attrs.name;
    };

    "40-${attrs.name}" = {
      inherit (attrs) dns;
      matchConfig.Name = attrs.name;
      networkConfig.IPVLAN = "shim-${attrs.name}";
      addresses = [
        {
          Address = "${attrs.address}/${toString attrs.prefixLength}";
          RouteMetric = 1;
        }
      ];
      routes = [
        {
          Gateway = "${attrs.gateway}";
          Destination = "0.0.0.0/0";
          Metric = 1;
        }
      ];
    };
    "50-shim-${attrs.name}" = {
      matchConfig.Name = "shim-${attrs.name}";
      addresses = [
        {
          Address = "${attrs.address}/${toString attrs.prefixLength}";
          RouteMetric = 0;
        }
      ];
      routes = [
        {
          Gateway = "${attrs.gateway}";
          Destination = "0.0.0.0/0";
          Metric = 0;
        }
      ];
    };
  };

  mkQuadlet = attrs: {
    ${attrs.interface} = {
      autoStart = true;
      networkConfig = {
        driver = "ipvlan";
        gateways = [ attrs.address ];
        subnets = [ "${attrs.subnet}/${toString attrs.prefixLength}" ];
        options.parent = attrs.interface;
      };
    };
  };
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
    bridges = mkOption {
      default = null;
      type = nullOr (
        listOf (submodule {
          options = {
            name = mkOption {
              type = str;
              description = "Name of the bridge";
            };
            interface = mkOption {
              type = str;
              description = "Parent interface used for bridge";
            };
            address = mkOption {
              type = str;
              description = "Ip address of the parent interface";
            };
            subnet = mkOption {
              type = str;
              description = "Subnet of the network without mask";
            };
            prefixLength = mkOption {
              type = ints.between 0 32;
              description = "Prefix length of parent interface";
            };
            dns = mkOption {
              type = listOf str;
              description = "List of DNS server to use";
            };
            gateway = mkOption {
              type = str;
              description = "Default gateway of parent interface";
            };
          };
        })
      );
      description = "Add bridge interface with shim to acces ipvlans based on bridge";
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
        dockerSocket.enable = true;

        # Required for containers under podman-compose to be able to talk to each other.
        defaultNetwork.settings.dns_enabled = true;
      };
      # Create podman bridge
      quadlet.networks = foldl (acc: x: acc // mkQuadlet x) { } cfg.bridges;
    };
    hardware.nvidia-container-toolkit.enable = config.holynix.gpu.nvidia.enable;

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

    # Bridge
    systemd.network = mkIf (cfg.bridges != null) {
      enable = true;
      netdevs = foldl (acc: x: acc // mkNetdevs x) { } cfg.bridges;
      networks = foldl (acc: x: acc // mkNetworks x) { } cfg.bridges;
    };
  };
}
