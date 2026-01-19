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
    enableZfs = mkOption {
      type = bool;
      default = false;
      description = "Enable ZFS if needed";
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
      zfs = mkIf cfg.enableZfs {
        autoScrub = {
          enable = true;
          interval = "weekly";
        };
      };
    };

    environment.systemPackages =
      with pkgs;
      mkIf cfg.ansibleTarget [
        python3
      ];

    # ZFS-Kernel-Module
    boot.supportedFilesystems = mkIf cfg.enableZfs [ "zfs" ];

    # Kernel-Parameter for ZFS
    boot.kernelPackages = mkIf cfg.enableZfs (mkForce latestKernelPackage);

    networking.hostId = mkIf cfg.enableZfs "1b6c3a18";

  };
}
