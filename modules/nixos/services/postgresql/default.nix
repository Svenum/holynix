{ config, lib, ... }:

with lib;
with lib.types;
let
  cfg = config.holynix.services.postgresql;
in
{
  options.holynix.services.postgresql = {
    enable = mkOption {
      type = bool;
      default = false;
      description = "Enable PostgreSQL";
    };
  };

  config = mkIf cfg.enable {
    services.postgresql = {
      enable = true;
    };
  };
}
