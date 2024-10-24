{ options, config, lib, ... }:

with lib;
with lib.types;
let
  cfg = config.holynix.vpn.tailscale;
in
{
  options.holynix.vpn.tailscale.enable = mkOption {
    type = bool;
    default = false;
    description = "Enable tailscale";
  };

  config = mkIf cfg.enable {
    services.tailscale.enable = true;
    services.tailscale.useRoutingFeatures = "both";
    networking.firewall.trustedInterfaces = [ "tailscale0" ];
    networking.firewall.checkReversePath = "loose";

    services.resolved.enable = true;
  };

}
