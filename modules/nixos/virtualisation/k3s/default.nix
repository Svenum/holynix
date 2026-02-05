{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
with lib.types;
let
  cfg = config.holynix.virtualisation.k3s;
in
{
  options.holynix.virtualisation.k3s = {
    enable = mkOption {
      type = bool;
      default = false;
      description = "Enalbe K3S";
    };
    clusterCIDR = mkOption {
      type = nullOr str;
      default = "";
      description = "CIDR for the pods inside of the Cluster";
    };
    tokenFile = mkOption {
      type = nullOr path;
      default = null;
      description = "Path to the file wich contains the token for k3s";
    };
    serverAddr = mkOption {
      type = nullOr str;
      default = null;
      description = "Address of the first K3S node";
    };
    enableHelm = mkOption {
      type = bool;
      default = true;
      description = "Enable and install Helm";
    };
    nfs = {
      enable = mkOption {
        type = bool;
        default = false;
        description = "enable NFS provider";
      };
      onlyNFS = mkOption {
        type = bool;
        default = false;
        description = "Disable local-storage provider";
      };
      server = mkOption {
        type = nullOr str;
        default = null;
        description = "Server FQDN/IP of the nfs server";
      };
      path = mkOption {
        type = nullOr str;
        default = null;
        description = "Path of the exptered share";
      };
      setDefault = mkOption {
        type = bool;
        default = cfg.nfs.onlyNFS;
        description = "Make nfs the default storage";
      };
    };
  };

  config = mkIf cfg.enable {
    # Enable K3S
    services.k3s = {
      enable = true;
      inherit (cfg) tokenFile;
      extraFlags = [
        "--cluster-cidr ${cfg.clusterCIDR}"
      ]
      ++ optional cfg.nfs.onlyNFS "--disable local-storage";
      clusterInit = true;
      serverAddr = mkIf (cfg.serverAddr != null) cfg.serverAddr;
      manifests = {
        nfs.content = {
          apiVersion = "helm.cattle.io/v1";
          kind = "HelmChart";
          metadata = {
            name = "nfs";
            namespace = "default";
          };
          spec = {
            chart = "nfs-subdir-external-provisioner";
            repo = "https://kubernetes-sigs.github.io/nfs-subdir-external-provisioner";
            targetNamespace = "default";
            set = {
              nfs = {
                inherit (cfg.nfs) server;
                inherit (cfg.nfs) path;
              };
              storageClass = {
                name = "nfs";
                reclaimPolicy = "Retain";
              };
            };
          };
        };
      };
    };

    boot.supportedFilesystems = mkIf cfg.nfs.enable [ "nfs" ];

    environment.systemPackages =
      with pkgs;
      mkIf cfg.enableHelm [
        kubernetes-helm
      ];

    # enable port
    networking.firewall = {
      allowedTCPPorts = [
        80
        443 # Traefik
        6443 # Kube API
        10250 # Metrics
      ];
      allowedTCPPortRanges = [
        # etcd
        {
          from = 2379;
          to = 2380;
        }
      ];
    };
  };
}
