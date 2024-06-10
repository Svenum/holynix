{ modulesPath, ... }:

{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  boot.initrd.availableKernelModules = [ "ahci", "xhci_pci", "virtio_pci", "sr_mod", "virtio_blk" ];
  boot.initrd.kernelModules = [];
  boot.kernelModules = [];
  boot.extraModulePackages = [];

  # Filesystems
  fileSystems."/" = {
    label = "NixOS";
    fsType = "ext4";
  };

  fileSystems."/boot" = {
    label = "Boot";
    fsType = "vfat";
  };
}
