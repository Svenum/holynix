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
      device = "/dev/disk/by-uuid/3ced7edf-0bad-423b-b323-dd1e5b4d8d7d";
      fsType = "btrfs";
      options = [ "subvol=@root" ];
    };

    "/nix" = {
      device = "/dev/disk/by-uuid/3ced7edf-0bad-423b-b323-dd1e5b4d8d7d";
      fsType = "btrfs";
      options = [ "subvol=@nix" ];
    };

    "/var/log" = {
      device = "/dev/disk/by-uuid/3ced7edf-0bad-423b-b323-dd1e5b4d8d7d";
      fsType = "btrfs";
      options = [ "subvol=@var-log" ];
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/0A77-7CFA";
      fsType = "vfat";
      options = [
        "fmask=0022"
        "dmask=0022"
      ];
    };
  };

  nixpkgs.hostPlatform = "x86_64-linux";
}
