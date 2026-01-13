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
    kernelModules = [ ];
    extraModulePackages = [ ];
  };

  # Filesystems
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

  nixpkgs.hostPlatform = "x86_64-linux";
}
