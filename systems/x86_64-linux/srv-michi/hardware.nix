{ lib, config, ... }:

{
  boot.initrd.availableKernelModules = [ "uhci_hcd" "ehci_pci" "ahci" "virtio_pci" "sr_mod" "virtio_blk" ];
  boot.kernelModules = [ "kvm-amd" ];

  fileSystems."/" = {
    device = "/dev/disk/";
    fsType = "ext4";
  };

  fileSystems."/home" = {
    device = "";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    device = "";
    fsType = "vfat";
  }
}
