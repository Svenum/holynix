{ lib, pkgs, ... }:

{
  hardware.raspberry-pi.config = {
    all.options = {
      arm_64bit = {
        enable = true;
        value = true;
      };

    };
  };
  raspberry-pi-nix.board = "bcm2712";

  boot.supportedFilesystems = {
    zfs = lib.mkForce false;
  };

  sdImage.compressImage = lib.mkForce false;
}
