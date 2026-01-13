{
  config,
  pkgs,
  lib,
  inputs,
  ...
}:

with lib;
with lib.types;
let
  cfg = config.holynix.virtualisation.kvm;

  isAMD = config.hardware.cpu.amd.updateMicrocode;
  isIntel = config.hardware.cpu.intel.updateMicrocode;
in
{
  imports = [ inputs.nixVirt.nixosModules.default ];

  options.holynix.virtualisation.kvm = {
    enable = mkOption {
      type = bool;
      default = false;
    };
    vfioPCIDevices = mkOption {
      type = nullOr (listOf str);
      default = null;
    };
  };

  config = mkIf cfg.enable {

    boot = {
      # Prepare Kernel
      extraModprobeConfig = mkIf (cfg.vfioPCIDevices != null) ''
        options vfio_pci ids=${strings.concatMapStrings (x: "," + x) cfg.vfioPCIDevices}
        options kvm ignore_msrs=1
        options kvm report_ignored_msrs=0
        options kvmfr static_size_mb=128
        ${if isAMD then "options kvm_amd nested=1" else ""}
      '';

      # Boot options
      kernelModules = [
        "vfio"
        "vfio_iommu_type1"
        "vfio_pci"
        "pci_stub"
      ]
      ++ lists.optionals isAMD [ "kvm-amd" ];
      kernelParams = [
        "iommu=pt"
      ]
      ++ lists.optionals isAMD [
        "amd_iommu=on"
        "kvm_amd.avic=1"
        "kvm_amd.npt=1"
      ]
      ++ lists.optionals isIntel [ "intel_iommu=on" ];

      initrd.kernelModules = [
        "vfio"
        "vfio-pci"
      ]
      ++ lists.optional isAMD "amdgpu";
    };

    # Toggle GPU script
    environment.systemPackages =
      with pkgs;
      [
        virtiofsd
      ]
      ++ lib.lists.optionals (cfg.vfioPCIDevices != null) [
        (pkgs.holynix.toggle-amd-gpu.override {
          dgpuPCI = cfg.vfioPCIDevices;
        })
      ];

    security.sudo.extraRules = mkIf (cfg.vfioPCIDevices != null) [
      {
        groups = [
          "kvm"
          "libvirtd"
        ];
        runAs = "ALL:ALL";
        commands = [
          {
            command = "/run/current-system/sw/bin/toggle-amd-gpu";
            options = [ "NOPASSWD" ];
          }
        ];
      }
    ];
  };
}
