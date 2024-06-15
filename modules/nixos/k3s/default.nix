{ options, config, lib, pkgs, ... }:

with lib;
with lib.types;
let
  cfg = config.holynix.k3s;
in
{
  options.holynix.k3s = {
    enable = mkOption {
      type = bool;
      default = false;
      description = "Enalbe K3S";
    };
    clusterCIDR = mkOption {
      type = nullOr (str);
      default = "";
      description = "CIDR for the pods inside of the Cluster";
    };
    tokenFile = mkOption {
      type = nullOr (path);
      default = null;
      description = "Path to the file wich contains the token for k3s";
    };
    serverAddress = mkOption {
      type = nullOr (str);
      default = null;
      description = "Address of the first K3S node";
    };
    enableHelm = mkOption {
      type = bool;
      default = true;
      description = "Enable and install Helm";
    };
  };

  config = mkIf cfg.enable {
    # Enable K3S
    services.k3s = {
      enable = true;
      tokenFile = cfg.tokenFile;
      extraFlags = "--cluster-cidr ${cfg.clusterCIDR}";
      clusterInit = true;
    };

    environment.systemPackages = with pkgs; mkIf cfg.enableHelm [
      kubernetes-helm
    ];

    # enable port
    networking.firewall = {
      allowedTCPPorts = [
        80 443 # Traefik
        6443   # Kube API
        10250  # Metrics
      ];
      allowedTCPPortRanges = [
        # etcd
        { from = 2379; to = 2380; }
      ];
    };
  };
}
