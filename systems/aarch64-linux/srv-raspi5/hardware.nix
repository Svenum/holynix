{ lib, pkgs, ... }:

{
  raspberry-pi-nix = {
    board = "bcm2712";
    uboot.enable = true;
  };

  boot.supportedFilesystems = {
    zfs = lib.mkForce false;
  };

  fileSystems."/" = {
    label = "NIXOS_SD";
    fsType = "ext4";
  };
  nixpkgs.hostPlatform = lib.mkDefault "aarch64-linux";
}
