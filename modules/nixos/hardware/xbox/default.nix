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
    # Xbox-Controller aktivieren
    hardware = {
      xpadneo.enable = true;
      bluetooth.settings = {
        General = {
          Privacy = "device";
          JustWorksRepairing = "always";
          Class = "0x000100";
          FastConnectable = true;
        };
      };
    };
  };
}
