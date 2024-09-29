{ options, config, lib, systemConfig, ... }:

with lib;
with lib.types;
let
  cfg = config.holynix.desktop.hyprland;
  localeCfg = systemConfig.holynix.locale;
in
{
  options.holynix.desktop.hyprland = {
    enable = mkOption {
      default = false;
      type = bool;
      description = "enable hyprland settings";
    };
    monitors = mkOption {
      default = [];
      type = listOf (str);
      description = "settings for the monitors";
    };
  };

  config = mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      enable = true;
      systemd.enableXdgAutostart = true;
      xwayland.enable = true;

      settings = {
        input = {
          kb_layout = strings.toLower (lists.last (strings.splitString "_" localeCfg.name));

          follow_mouse = 1;
        };

        gestures = {
          workspace_swipe = true;
        };

        monitor = [
          ",preferred,auto,auto"
        ] ++ cfg.monitors;

        general = {
          gaps_in = 5;
          gaps_out = 20;
          border_size = 2;
          layout = "dwindle";
        };

        decoration = {
          rounding = 10;
          active_opacity = "1.0";
          inactive_opacity = "0.9";

          drop_shadows = true;
          shadow_range = 4;
          shadow_render_power = 3;
        };

        env = [
          "XCURSOR_SIZE,24"
          "HYPRCURSOR_SIZE,24"
        ];
      };
    };
  };
}
