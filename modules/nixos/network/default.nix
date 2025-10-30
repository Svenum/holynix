{ config, lib, ... }:

with lib;
with lib.types;
let
  cfg = config.holynix.network;
  typeCfg = config.holynix.systemType;
in
{
  options.holynix.network = {
    enable = mkOption {
      type = bool;
      default = false;
    };
    useIWD = mkOption {
      type = bool;
      default = true;
      description = "Enable iwd as backend";
    };
  };

  config = mkIf cfg.enable {
    networking = {
      nftables.enable = true;
      networkmanager = {
        enable = true;
        wifi.backend = mkIf cfg.useIWD "iwd";
        plugins = mkIf typeCfg.server.enable (mkForce [ ]);
      };
    };
  };
}
