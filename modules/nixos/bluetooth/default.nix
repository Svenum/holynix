{ config, lib, ... }:

with lib;
with lib.types;
let
  cfg = config.holynix.bluetooth;
in
{
  options.holynix.bluetooth.enable = mkOption {
    type = bool;
    default = false;
  };

  config = mkIf cfg.enable {
    hardware.bluetooth = {
      enable = true;
      settings = {
        General = {
          Experimental = true;
        };
      };
    };
  };
}
