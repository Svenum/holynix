{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
with lib.types;

let
  cfg = config.holynix.desktop.steammachine;
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

    programs.steam.extraPackages = with pkgs; [
      fuse
      fuse3
    ];

    jovian = {
      steam = {
        enable = true;
        updater.splash = "vendor";
      };
      steamos.useSteamOSConfig = false;
      hardware = {
        has.amd.gpu = cfg.hasAmdGpu;
      };
      decky-loader = {
        enable = true;
        extraPackages =
          lists.optional config.programs.kdeconnect.enable pkgs.kdePackages.kdeconnect-kde
          ++ lists.optional config.services.tailscale.enable pkgs.tailscale;
      };
    };
  };

}
