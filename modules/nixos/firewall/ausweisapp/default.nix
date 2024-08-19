{ options, config, lib, ... }:

with lib;
with lib.types;
let
  cfg = config.holynix.firewall.ausweisapp;
in
{
  options.holynix.firewall.ausweisapp.open = mkOption {
    default = false;
    type = bool;
    description = "Open The firewall for the AusweisApp";
  };

  config = mkIf cfg.open {
    networking.firewall = {
      allowedUDPPorts = [ 24727 ];
      allowedTCPPorts = [ 24727 ];
    };
  };
}
