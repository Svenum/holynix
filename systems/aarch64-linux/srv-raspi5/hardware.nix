{
  lib,
  pkgs,
  nixos-raspberrypi,
  ...
}:

{
  boot = {
    supportedFilesystems = {
      zfs = lib.mkForce false;
    };
    loader = {
      generic-extlinux-compatible.enable = lib.mkForce false;
      raspberry-pi.bootloader = "kernel";
    };
    kernelPackages = nixos-raspberrypi.packages.${pkgs.stdenv.hostPlatform.system}.linuxPackages_rpi5;
  };

  hardware.deviceTree.enable = true;

  fileSystems."/" = {
    label = "NIXOS_SD";
    fsType = "ext4";
  };
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
}
