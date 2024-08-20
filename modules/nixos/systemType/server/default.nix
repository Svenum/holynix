{ options, config, lib, ... }:

with lib;
with lib.types;
let
  cfg = config.holynix.systemType.server;
in
{
  options.holynix.systemType.server = {
    enable = mkOption {
      type = bool;
      default = false;
      description = "Enable server specific features";
    };
  };
  config = mkIf cfg.enable {
    # Node Exporter
    services.prometheus.exporters.node = {
      enable = true;
      openFirewall = true;
    };

    # SSH
    services.openssh.enable = true;
  };
}
