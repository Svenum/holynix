{ lib, pkgs, ... }:

{
  boot = {
    supportedFilesystems = {
      zfs = lib.mkForce false;
    };
    loader = {
      generic-extlinux-compatible.enable = lib.mkForce false;
      raspberry-pi.bootloader = "kernel";
    };
    kernelPackages = lib.mkForce pkgs.linuxPackages_rpi5;
  };

  hardware.deviceTree.enable = true;

  fileSystems."/" = {
    label = "NIXOS_SD";
    fsType = "btrfs";
  };
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
}
