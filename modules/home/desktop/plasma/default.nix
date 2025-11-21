{ config, lib, systemConfig, ... }:

with lib;
with lib.types;
let
  cfg = config.holynix.desktop.plasma;
  themeCfg = systemConfig.holynix.theme;
in
{
  options.holynix.desktop.plasma = {
    enable = mkOption {
      default = false;
      type = bool;
      description = "enable plasma-manager";
    };
    themeFlavour = mkOption {
      default = strings.toLower themeCfg.flavor;
      type = str;
      description = "theme flavor";
    };
    themeAccent = mkOption {
      default = strings.toLower themeCfg.accent;
      type = str;
      description = "theme accent";
    };
    cursorFlavour = mkOption {
      default = strings.toLower themeCfg.flavor;
      type = str;
      description = "cursor flavor";
    };
    cpuRange = mkOption {
      default = 100;
      type = int;
      description = "cpu threads * 100 = cpuRange";
    };
    launchers = mkOption {
      default = [
        "applications:org.kde.dolphin.desktop"
        "preferred://browser"
      ];
      type = listOf str;
      description = "Launchers that are in the side panel";
    };
    enableGPUSensor = mkOption {
      default = false;
      type = bool;
      description = "enable GPU Sensor in panel";
    };
  };

  config = mkIf cfg.enable {

    programs.plasma = {
      enable = true;

      # Add Virtual Desktops
      kwin = {
        effects = {
          shakeCursor.enable = true;
          desktopSwitching.animation = "slide";
        };
        virtualDesktops = {
          rows = 2;
          names = [
            "MAIN TOP"
            "SEC TOP"
            "MAIN BOT"
            "SEC BOT"
          ];
          number = 4;
        };
      };

      # Configure Spectacle
      configFile."spectaclerc" = {
        "Desktop" = {
          "clipboardGroup".value = "PostScreenshotCopyImage";
          "launchAction".value = "UseLastUsedCapturemode";
          "rememberSelectionRect".value = "Always";
        };
        "GuiConfig" = {
          "captureMode".value = 0;
          "quitAfterSaveCopyExport".value = true;
        };
      };

      # Enable NumLock
      configFile."kcminputrc".Keyboard.NumLock.value = 0;

      # Theming
      workspace = {
        clickItemTo = "select";
        theme = "default";
        colorScheme = "Catppuccin${cfg.themeFlavour}${cfg.themeAccent}";
        cursor.theme = "Catppuccin-${cfg.cursorFlavour}-${cfg.themeAccent}-Cursors";
        wallpaper = "/etc/wallpaper/catppuccin-${lib.strings.toLower themeCfg.flavor}.jpg";
      };

      panels = [
        {
          location = "left";
          hiding = "dodgewindows";
          alignment = "right";
          floating = false;
          widgets = [
            "org.kde.plasma.panelspacer"
            {
              name = "org.kde.plasma.icontasks";
              config = {
                General = {
                  inherit (cfg) launchers;
                };
              };
            }
            "org.kde.plasma.panelspacer"
          ];
          height = 50;
        }
        {
          location = "top";
          hiding = "dodgewindows";
          alignment = "center";
          floating = false;
          widgets = [
            "org.kde.plasma.appmenu"
            "org.kde.plasma.panelspacer"
            {
              name = "org.kde.plasma.digitalclock";
              config = {
                Appearance = {
                  dateDisplayFormat = "BesideTime";
                  dateFormat = "longDate";
                };
              };
            }
            "org.kde.plasma.pager"
            "org.kde.plasma.panelspacer"
            "org.kde.plasma.systemmonitor.memory"
            {
              name = "org.kde.plasma.systemmonitor.cpucore";
              config = {
                Appearance = {
                  chartFace = "org.kde.ksysguard.piechart";
                };
                "org.kde.ksysguard.piechart/General" = {
                  rangeTo = cfg.cpuRange;
                  rangeAuto = "false";
                };
              };
            }
            (mkIf cfg.enableGPUSensor {
              name = "org.kde.plasma.systemmonitor";
              config = {
                Sensors = {
                  highPrioritySensorIds = ''[\"gpu/all/usage\"]'';
                  totalSensors = ''[\"gpu/all/usage\"]'';
                };
              };
            })
            {
              name = "org.kde.plasma.panelspacer";
              config = {
                General = {
                  length = "10";
                  expanding = "false";
                };
              };
            }
            "org.kde.plasma.systemtray"
            {
              name = "org.kde.plasma.shutdownorswitch";
              config = {
                General = {
                  showIcon = "true";
                  showName = "false";
                  showFullName = "false";
                  showLockScreen = "false";
                  showHybernate = "true";
                  showSuspend = "true";
                  showNewSession = "false";
                  showUsers = "false";
                  showText = "true";
                };
              };
            }
          ];
          height = 30;
        }
        {
          location = "top";
          hiding = "dodgewindows";
          screen = 1;
          alignment = "center";
          floating = false;
          widgets = [
            "org.kde.plasma.appmenu"
            "org.kde.plasma.panelspacer"
            {
              name = "org.kde.plasma.digitalclock";
              config = {
                Appearance = {
                  dateDisplayFormat = "BesideTime";
                  dateFormat = "longDate";
                  enabledCalendarPlugins = "holidaysevents,pimevents";
                };
              };
            }
            "org.kde.plasma.panelspacer"
          ];
          height = 30;
        }
      ];

      shortcuts = {
        kwin = {
          # Switch Desktop
          "Switch One Desktop Down" = "Ctrl+Alt+Down";
          "Switch One Desktop Up" = "Ctrl+Alt+Up";
          "Switch One Desktop to the Left" = "Ctrl+Alt+Left";
          "Switch One Desktop to the Right" = "Ctrl+Alt+Right";
          # Move Window to diffrent Desktop
          "Window One Desktop Down" = "Meta+Ctrl+Alt+Down";
          "Window One Desktop Up" = "Meta+Ctrl+Alt+Up";
          "Window One Desktop to the Left" = "Meta+Ctrl+Alt+Left";
          "Window One Desktop to the Right" = "Meta+Ctrl+Alt+Right";
        };
      };
    };
  };
}
