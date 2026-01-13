{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
with lib.types;
let
  cfg = config.holynix.hardware.headsetcontrol;
in
{
  options.holynix.hardware.headsetcontrol.enable = mkEnableOption {
    default = false;
    description = "Enable headsetcontrol and its udev rules";
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.headsetcontrol ];
    services.udev.packages = [ pkgs.headsetcontrol ];
  };
}
