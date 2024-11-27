{ lib, pkgs, ... }:

{
  raspberry-pi-nix = {
    board = "bcm2712";
    uboot.enable = false;
  };

  boot.supportedFilesystems = {
    zfs = lib.mkForce false;
  };

  fileSystems."/" = {
    label = "NIXOS_SD";
    fsType = "ext4";
  };
}
