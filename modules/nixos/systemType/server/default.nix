{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
with lib.types;
let
  cfg = config.holynix.systemType.server;
  zfsCompatibleKernelPackages = lib.filterAttrs (
    name: kernelPackages:
    (builtins.match "linux_[0-9]+_[0-9]+" name) != null
    && (builtins.tryEval kernelPackages).success
    && (!kernelPackages.${config.boot.zfs.package.kernelModuleAttribute}.meta.broken)
  ) pkgs.linuxKernel.packages;
  latestKernelPackage = lib.last (
    lib.sort (a: b: (lib.versionOlder a.kernel.version b.kernel.version)) (
      builtins.attrValues zfsCompatibleKernelPackages
    )
  );

  mkDatasets = attrs: {
    "${attrs.dataset}" = {
      useTemplate = [ attrs.frequenz ];
      recursive = true;
    };
  };
in
{
  options.holynix.systemType.server = {
    enable = mkOption {
      type = bool;
      default = false;
      description = "Enable server specific features";
    };
    ansibleTarget = mkOption {
      type = bool;
      default = false;
      description = "If true everything gets setup to be a ansible target";
    };
    zfs = {
      enable = mkOption {
        type = bool;
        default = false;
        description = "Enable ZFS if needed";
      };
      hostId = mkOption {
        type = str;
        description = "HostId needed for zfs";
      };
      snapshots = mkOption {
        default = null;
        type = types.nullOr (
          types.listOf (
            types.submodule {
              options = {
                dataset = mkOption {
                  type = types.str;
                  description = "Name of dataset";
                };
                frequenz = mkOption {
                  type = types.enum [
                    "high"
                    "medium"
                    "low"
                    "very_low"
                  ];
                  default = "medium";
                  description = "Snapshot frequenzie";
                };
              };
            }
          )
        );
      };
    };
  };
  config = mkIf cfg.enable {

    services = {
      # Node Exporter
      prometheus.exporters.node = {
        enable = true;
        openFirewall = true;
      };
      # SSH
      openssh.enable = true;
      # ZFS-Services
      zfs = mkIf cfg.zfs.enable {
        autoScrub = {
          enable = true;
          interval = "weekly";
        };
      };

      sanoid = mkIf (cfg.zfs.enable && cfg.zfs.snapshots != null) {
        enable = true;
        templates = {
          "high" = {
            hourly = 48;
            daily = 14;
            weekly = 8;
            monthly = 6;
            autosnap = true;
            autoprune = true;
          };
          "medium" = {
            hourly = 24;
            daily = 30;
            weekly = 12;
            monthly = 12;
            autosnap = true;
            autoprune = true;
          };
          "low" = {
            hourly = 12;
            daily = 7;
            weekly = 4;
            monthly = 6;
            autosnap = true;
            autoprune = true;
          };
          "very_low" = {
            hourly = 0;
            daily = 7;
            weekly = 4;
            monthly = 3;
            autosnap = true;
            autoprune = true;
          };
        };
        datasets = foldl (acc: x: acc // mkDatasets x) { } cfg.zfs.snapshots;
      };
    };

    environment.systemPackages =
      with pkgs;
      mkIf cfg.ansibleTarget [
        python3
      ];

    # ZFS-Kernel-Module
    boot.supportedFilesystems = mkIf cfg.zfs.enable [ "zfs" ];
    # Kernel-Parameter for ZFS
    boot.kernelPackages = mkIf cfg.zfs.enable (mkForce latestKernelPackage);
    networking.hostId = mkIf cfg.zfs.enable cfg.zfs.hostId;
  };
}
