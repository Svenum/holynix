{ options, config, lib, ... }:

with lib;
with lib.types;
let
  cfg = config.holynix.systemType.cloud;
in
{
  options.holynix.systemType.cloud.enable = mkOption{
    default = false;
    type = bool;
    description = "Enable all what is needed to runa cloud vm";
  };

  config = mkIf cfg.enable {
    kexec.autoReboot = false;
    boot.kernelParams = [ "net.ifnames=0" ];
  };
}
