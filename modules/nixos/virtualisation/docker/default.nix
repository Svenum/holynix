{ options, config, lib, ... }:

with lib;
with lib.types;
let
  cfg = config.holynix.virtualisation.docker;
in
{
  options.holynix.virtualisation.docker = {
    enable = mkOption {
      type = bool;
      default = false;
      description = "Enable docker";
    };
    defaultAddressPool = {
      base = mkOption {
        type = str;
        default = "10.10.0.0/16";
        description = "Subnet for default pool";
      };
      size = mkOption {
        type = int;
        default = 24;
        description = "Size of default docker networks";
      };
    };
  };

  config = mkIf cfg.enable {
    virtualisation.docker = {
      enable = true;
      daemon.settings = {
        default-address-pools = [
          {
            base = cfg.defaultAddressPool.base;
            size = cfg.defaultAddressPool.size;
          }
        ];
      };
      autoPrune.enable = true;
    };
  };
}
