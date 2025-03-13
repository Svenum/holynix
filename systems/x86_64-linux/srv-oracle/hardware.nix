{ lib, ... }:

{
  boot.initrd.availableKernelModules = [ "ata_piix" "uhci_hcd" "virtio_pci" "virtio_scsi" "sd_mod" ];

  boot.initrd.kernelModules = [];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [];

  swapDevices = [{
    device = "/var/lib/swapfile";
    size = 4 * 1024;
  }];

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
