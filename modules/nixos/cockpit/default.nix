{ options, config, lib, ... }:

with lib;
with lib.types;
let
  cfg = config.holynix.cockpit;
in
{
  options.holynix.cockpit.enable = mkOption {
    type = bool;
    default = false;
    description = "Enable Cockpit";
  };

  config = mkIf cfg.enable {
    services.cockpit = {
      enable = true;
      openFirewall = true;
    };
  };
}
