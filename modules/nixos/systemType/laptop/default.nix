{ options, config, lib, ... }:

with lib;
with lib.types;
let
  cfg = config.holynix.systemType.laptop;
in
{
  options.holynix.systemType.laptop = {
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
