{ config, lib, modulesPath, ... }:

{
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot = {
    initrd = {
      availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" "rtsx_pci_sdmmc" ];
      kernelModules = [ ];
    };
    kernelModules = [ "kvm-intel" ];
    extraModulePackages = [ ];
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/cf9aa932-27d7-4743-84fe-57963e935e93";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/F9CD-7AD0";
      fsType = "vfat";
      options = [ "fmask=0022" "dmask=0022" ];
    };

    "/home" = {
      device = "/dev/disk/by-uuid/3497cccd-a50b-4b72-a1b5-7bdce5d54449";
      fsType = "ext4";
    };

    swapDevices = [ ];

    networking.useDHCP = lib.mkDefault true;

    nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
    hardware.cpu.intel.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
  };
}
