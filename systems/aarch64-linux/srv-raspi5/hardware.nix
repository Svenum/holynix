{ lib, pkgs, ... }:

{
  raspberry-pi-nix = {
    board = "bcm2712";
    uboot.enable = true;
  };

  boot.supportedFilesystems = {
    zfs = lib.mkForce false;
  };

  sdImage.compressImage = lib.mkForce false;
}
