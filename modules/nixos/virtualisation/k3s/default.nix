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
        nfs-provisioner.content = mkIf cfg.nfs.enable [
          {
            apiVersion = "v1";
            kind = "Namespace";
            metadata.name = "nfs-provisioner";
          }
          {
            apiVersion = "v1";
            kind = "ServiceAccount";
            metadata = {
              name = "nfs-client-provisioner";
              namespace = "nfs-provisioner";
            };
          }
          {
            apiVersion = "rbac.authorization.k8s.io/v1";
            kind = "ClusterRole";
            metadata.name = "nfs-client-provisioner-runner";
            rules = [
              {
                apiGroups = [ "" ];
                resources = [ "persistentvolumes" ];
                verbs = [
                  "get"
                  "list"
                  "watch"
                  "create"
                  "delete"
                ];
              }
              {
                apiGroups = [ "" ];
                resources = [ "persistentvolumeclaims" ];
                verbs = [
                  "get"
                  "list"
                  "watch"
                  "update"
                ];
              }
              {
                apiGroups = [ "storage.k8s.io" ];
                resources = [ "storageclasses" ];
                verbs = [
                  "get"
                  "list"
                  "watch"
                ];
              }
              {
                apiGroups = [ "" ];
                resources = [ "events" ];
                verbs = [
                  "create"
                  "update"
                  "patch"
                ];
              }
            ];
          }
          {
            apiVersion = "rbac.authorization.k8s.io/v1";
            kind = "ClusterRoleBinding";
            metadata.name = "run-nfs-client-provisioner";
            subjects = [
              {
                kind = "ServiceAccount";
                name = "nfs-client-provisioner";
                namespace = "nfs-provisioner";
              }
            ];
            roleRef = {
              kind = "ClusterRole";
              name = "nfs-client-provisioner-runner";
              apiGroup = "rbac.authorization.k8s.io";
            };
          }
          {
            apiVersion = "storage.k8s.io/v1";
            kind = "StorageClass";
            metadata = {
              name = "nfs-storage";
            }
            // lib.optionalAttrs cfg.nfs.setDefault {
              annotations."storageclass.kubernetes.io/is-default-class" = "true";
            };
            provisioner = "k8s-sigs.io/nfs-subdir-external-provisioner";
            reclaimPolicy = "Retain";
            parameters.archiveOnDelete = true;
          }
          {
            apiVersion = "apps/v1";
            kind = "Deployment";
            metadata = {
              name = "nfs-client-provisioner";
              namespace = "nfs-provisioner";
            };
            spec = {
              replicas = 1;
              selector.matchLabels.app = "nfs-client-provisioner";
              strategy.type = "Recreate";
              template = {
                metadata.labels.app = "nfs-client-provisioner";
                spec = {
                  serviceAccountName = "nfs-client-provisioner";
                  containers = [
                    {
                      name = "nfs-client-provisioner";
                      image = "registry.k8s.io/sig-storage/nfs-subdir-external-provisioner:v4.0.2";
                      volumeMounts = [
                        {
                          name = "nfs-client-root";
                          mountPath = "/persistentvolumes";
                        }
                      ];
                      env = [
                        {
                          name = "PROVISIONER_NAME";
                          value = "k8s-sigs.io/nfs-subdir-external-provisioner";
                        }
                        {
                          name = "NFS_SERVER";
                          value = cfg.nfs.server;
                        }
                        {
                          name = "NFS_PATH";
                          value = cfg.nfs.path;
                        }
                      ];
                    }
                  ];
                  volumes = [
                    {
                      name = "nfs-client-root";
                      nfs = {
                        inherit (cfg.nfs) server;
                        inherit (cfg.nfs) path;
                      };
                    }
                  ];
                };
              };
            };
          }
        ];
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
