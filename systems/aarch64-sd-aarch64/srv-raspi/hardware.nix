{ lib, pkgs, ... }:

{
  boot.kernelPackages = lib.mkForce pkgs.linuxKernel.packages.linux_rpi4;

  boot.loader = {
    grub.enable = lib.mkForce false;
    generic-extlinux-compatible.enable = lib.mkForce true;
  };
}
