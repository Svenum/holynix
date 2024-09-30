{ options, config, lib, systemConfig, ... }:

with lib;
with lib.types;
let
  cfg = config.holynix.desktop.hyprland;
  localeCfg = systemConfig.holynix.locale;
  themeCfg = systemConfig.holynix.theme;
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
    services.hyprpaper = {
      enable = true;
      settings = {
        ipc = "on";
        splash = false;
        splash_offset = 2.0;

        preload = [ "/etc/wallpaper/catppuccin-${lib.strings.toLower themeCfg.flavour}.jpg" ];

        wallpaper = ", /etc/wallpaper/catppuccin-${lib.strings.toLower themeCfg.flavour}.jpg";
      };
    };
    wayland.windowManager.hyprland = {
      enable = true;
      systemd.enableXdgAutostart = true;
      systemd.variables = ["--all"];
      xwayland.enable = true;

      settings = {
        input = {
          kb_layout = strings.toLower (lists.last (strings.splitString "_" localeCfg.name));

          follow_mouse = 1;
          touchpad = {    
            natural_scroll = "no";    
          };
          sensitivity = 0; 
        };

        gestures = {
          workspace_swipe = true;
        };

        general = {
          gaps_in = 5;
          gaps_out = 20;
          border_size = 2;
          "col.active_border" = "rgba(#2d1d7a) rgba(#df8046) 45deg";  
          "col.inactive_border" = "rgba(595959aa)";
          layout = "dwindle";
          resize_on_border = true;
        };

        monitor = [
          ",preferred,auto,auto"
        ] ++ cfg.monitors;

        decoration = {
          rounding = 10;
          active_opacity = "1.0";
          inactive_opacity = "0.9";

          drop_shadow = true;
          shadow_range = 4;
          shadow_render_power = 3;
      
          blur = {    
            enabled = true;
            size = 3;
            passes = 1;
          };
      
          "col.shadow" = "rgba(1a1a1aee)";
        };

        animations = {
          enabled = true;
          bezier = "myBezier, 0.05, 0.9, 0.1, 1.05";
      
          animation = [
            "windows, 1, 7, myBezier"
            "windowsOut, 1, 7, default, popin 80%"
            "border, 1, 10, default"
            "borderangle, 1, 8, default"
            "fade, 1, 7, default"
            "workspaces, 1, 6, default"
          ];
        };
      
        dwindle = {
          pseudotile = true;
          preserve_split = true;
        };
        
        env = [
          "XCURSOR_SIZE,24"
          "HYPRCURSOR_SIZE,24"
        ];

        "$mainMod" = "ALT1";
        "$secondMod" = "Win";

        bind = [
          "$mainMod&CTRL, T, exec, kitty"
          "$mainMod&CTRL, B, exec, xdg-open https://"
          "$mainMod, Q, killactive"
          "$mainMod, SPACE, wofi --show drun"
        ];
      };
    };
  };
}
