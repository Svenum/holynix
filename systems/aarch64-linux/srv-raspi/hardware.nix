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

}
