{ options, config, lib, ... }:

with lib;
with lib.types;
let
  cfg = config.holynix.hardware.laptop;
in
{
  options.holynix.hardware.laptop = {
    enable = mkOption {
      type = bool;
      default = false;
      description = "Enable laptop specific features";
    };
  };

  config = mkIf cfg.enable {
    services.libinput.touchpad.disableWhileTyping = true;
  };
}
