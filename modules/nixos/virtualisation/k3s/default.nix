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
    domain = mkOption {
      type = nullOr str;
      default = null;
      description = "Domain for the cluster!";
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
    services = {
      rpcbind.enable = cfg.nfs.enable;
      k3s = {
        enable = true;
        inherit (cfg) tokenFile;
        extraFlags = [
          "--cluster-cidr ${cfg.clusterCIDR}"
        ]
        ++ optional cfg.nfs.onlyNFS "--disable local-storage";
        clusterInit = true;
        serverAddr = mkIf (cfg.serverAddr != null) cfg.serverAddr;
        manifests = mkIf (cfg.serverAddr == null) {
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
              targetNamespace = "kube-system";
              set = {
                "nfs.server" = cfg.nfs.server;
                "nfs.path" = cfg.nfs.path;
                "storageClass.name" = "nfs";
                "storageClass.reclaimPolicy" = "Retain";
                "storageClass.defaultClass" = toString cfg.nfs.setDefault;
              };
            };
          };
        };
        autoDeployCharts = mkIf (cfg.serverAddr == null) {
          rancher = {
            enable = true;

            repo = "https://releases.rancher.com/server-charts/stable";
            name = "rancher";
            version = "stable";

            targetNamespace = "cattle-system";
            createNamespace = true;

            values = {
              hostname = "rancher." + cfg.domain;

              persistence = {
                storageClass = "nfs";
              };

              bootstrapPassword = "rancher";

              replicas = 3;
            };
          };
          cert-manager = {
            enable = true;
            repo = "https://charts.jetstack.io";
            name = "cert-manager";
            version = "v1.14.0";
            targetNamespace = "cert-manager";
            createNamespace = true;
            values = {
              installCRDs = true;
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
      interfaces = {
        "cni0".allowedUDPPorts = [ 53 ];
        "flannel.1".allowedUDPPorts = [ 53 ];
      };
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
