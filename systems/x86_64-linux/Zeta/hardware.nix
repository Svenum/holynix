{ lib, config, ... }:

{
  # Intel CPU Driver
  hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;

  # Configure Kernel
  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "firewire_ohci" "usb_storage" "sd_mod" "sr_mod" ];
  boot.kernelModules = [ "kvm-intel" "sg" ];
  # Maybe mds=full,nosmt
  boot.kernelParams = ["mds=full" "efi=runtime" "iommu=pt" "intel_iommu=on" ];

  # Configure RAID
  boot.swraid = {
    enable = true; 
    mdadmConf = ''
      # automatically tag new arrays as belonging to the local system
      HOMEHOST <system>

      # instruct the monitoring daemon where to send mail alerts
      MAILADDR root

      # definitions of existing MD arrays
      ARRAY /dev/md/1  metadata=1.2 UUID=b9c00b97:f6bcf7d4:d0660752:947755d1 name=Zeta:1
    '';
  };

  # Configure Filesystem
  fileSystems."/" =
    { device = "/dev/disk/by-uuid/bc414e42-a691-432c-aeab-dff20179d68d";
      fsType = "ext4";
    };

  fileSystems."/home" =
    { device = "/dev/disk/by-uuid/0a0605a5-c2d5-4e61-a826-11ff73d9239f";
      fsType = "ext4";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/F384-FF99";
      fsType = "vfat";
    };
  fileSystems."/mnt/ubuntu" =
    { device = "/dev/disk/by-uuid/496b6388-8a7c-46cb-9b2e-7f727bb51861";
      fsType = "ext4";
    };
}
