{ options, config, lib, ... }:

with lib;
with lib.types;
let
  cfg = config.holynix.systemType.vm;
in
{
  options.holynix.systemType.vm = {
    enable = mkOption {
      type = bool;
      default = false;
      description = "Enable vm specific features";
    };
  };
  config = mkIf cfg.enable {
    # Libvirt Guest Agents
    services.qemuGuest.enable = true;
    services.spice-vdagentd.enable = true;
  };
}
