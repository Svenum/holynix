{ modulesPath, ... }:

{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
  ];

  boot = {
    initrd = {
      availableKernelModules = [
        "ahci"
        "xhci_pci"
        "virtio_pci"
        "sr_mod"
        "virtio_blk"
      ];
      kernelModules = [ ];
    };
    kernelModules = [ "kvm-amd" ];
    extraModulePackages = [ ];
  };

  # Filesystems
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/ba86d10f-029f-4048-8ae7-3454f0f8f2fa";
      fsType = "btrfs";
      options = [ "subvol=@root" ];
    };

    "/nix" = {
      device = "/dev/disk/by-uuid/ba86d10f-029f-4048-8ae7-3454f0f8f2fa";
      fsType = "btrfs";
      options = [ "subvol=@nix" ];
    };

    "/var/log" = {
      device = "/dev/disk/by-uuid/ba86d10f-029f-4048-8ae7-3454f0f8f2fa";
      fsType = "btrfs";
      options = [ "subvol=@var-log" ];
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/B978-DB8A";
      fsType = "vfat";
      options = [
        "fmask=0022"
        "dmask=0022"
      ];
    };
  };

  nixpkgs.hostPlatform = "x86_64-linux";
}
