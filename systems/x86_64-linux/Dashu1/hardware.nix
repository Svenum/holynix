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
      device = "/dev/disk/by-uuid/a39bfdb5-4c1f-491e-b33a-4886651391de";
      fsType = "btrfs";
      options = [ "subvol=@root" ];
    };

    "/nix" = {
      device = "/dev/disk/by-uuid/a39bfdb5-4c1f-491e-b33a-4886651391de";
      fsType = "btrfs";
      options = [ "subvol=@nix" ];
    };

    "/var/log" = {
      device = "/dev/disk/by-uuid/a39bfdb5-4c1f-491e-b33a-4886651391de";
      fsType = "btrfs";
      options = [ "subvol=@var-log" ];
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/A124-2919";
      fsType = "vfat";
      options = [
        "fmask=0022"
        "dmask=0022"
      ];
    };
  };

  nixpkgs.hostPlatform = "x86_64-linux";
}
