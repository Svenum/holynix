{ lib, ... }:

{
  boot = {
    initrd = {
      availableKernelModules = [
        "uhci_hcd"
        "ehci_pci"
        "ahci"
        "virtio_pci"
        "sr_mod"
        "virtio_blk"
      ];
      kernelModules = [ ];
    };
    kernelModules = [ "kvm-amd" ];
    extraModulePackages = [ ];
  };

  fileSystems = {
    "/" = {
      device = "/dev/vda2";
      fsType = "ext4";
    };
    "/boot" = {
      device = "/dev/vda1";
      fsType = "vfat";
    };
  };

  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 8 * 1024; # 16 GiB
    }
  ];
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
