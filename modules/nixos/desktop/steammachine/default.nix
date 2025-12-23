{ config, lib, ... }:

with lib;
with lib.types;

let
  cfg = config.holynix.desktop.steammachine;
  plasmaCfg = config.holynix.desktop.plasma;
in
{
  options.holynix.desktop.steammachine = {
    enable = mkOption {
      type = bool;
      default = false;
      description = "Enable steammachine UI";
    };
    hasAmdGpu = mkOption {
      type = bool;
      default = false;
      description = "Set amd gpu to enable more perfomance features";
    };
  };

  config = mkIf cfg.enable {
    # Enable default desktop settings
    holynix = {
      desktop.enable = true;
    };

    jovian = {
      steam = {
        enable = true;
        desktopSession = mkIf plasmaCfg.enable "plasma";
        updater.splash = "vendor";
      };
      steamos = {
        enableDefaultCmdlineConfig = false;
        enableZram = false;
      };
      hardware = {
        has.amd.gpu = cfg.hasAmdGpu;
      };
      decky-loader.enable = false;
    };
  };

}
