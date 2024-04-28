{ options, config, lib, ... }:

with lib;
with lib.types;
let
  cfg = config.holynix.network;
in
{
  options.holynix.network = {
    enable = mkOption {
      type = bool;
      default = false;
    };
  };

  config = mkIf cfg.enable {
    networking = {
      networkmanager = {
        enable = true;
        wifi.backend = "iwd";
      };
    };
  };
}
