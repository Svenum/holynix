{
  config,
  lib,
  pkgs,
  ...
}:

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
    ansibleTarget = mkOption {
      type = bool;
      default = false;
      description = "If true everything gets setup to be a ansible target";
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

    environment.systemPackages =
      with pkgs;
      mkIf cfg.ansibleTarget [
        python3
      ];
  };
}
