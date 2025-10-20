{ config, lib, ... }:

with lib;
with lib.types;
let
  cfg = config.holynix.hardware.xbox;
in
{
  options.holynix.hardware.xbox.enable = mkEnableOption {
    default = false;
    description = "Enable xbox driver";
  };

  config = mkIf cfg.enable {
    hardware.xpadneo.enable = true;
  };
}
