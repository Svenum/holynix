{ lib, ... }:

{
  boot = {
    initrd = {
      availableKernelModules = [ "uhci_hcd" "ehci_pci" "ahci" "virtio_pci" "sr_mod" "virtio_blk" ];
      kernelModules = [ ];
    };
    kernelModules = [ "kvm-amd" ];
    extraModulePackages = [ ];
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/8063b9f6-d01b-42b5-a7fe-54048fa57885";
      fsType = "ext4";
    };

    "/home" = {
      device = "/dev/disk/by-uuid/cf28c758-046d-413b-a431-a314b17294fa";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/A7C9-4576";
      fsType = "vfat";
    };
  };

  swapDevices = [ ];
  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
