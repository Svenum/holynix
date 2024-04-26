{ lib, host, osConfig ? {}, ... }:

let
  # Checks
  isYon = host == "Yon";
  issrv-nixostest = host == "srv-nixostest";
  themeCfg = osConfig.holynix.theme;
  isLatte = themeCfg.flavour == "latte";
  isMocha = themeCfg.flavour == "mocha";
  isTeal = themeCfg.flavour == "teal";
  
  # Vars
  cursorFlavour = if isLatte then "Mocha" else "Latte";
  themeAccent = if isTeal == "teal" then "Teal" else "";
  themeFlavour = if isLatte == "latte" then "Latte" else "Mocha";
  range = if isYon then
      "1600"
    else if issrv-nixostest then
      "400"
    else
      "100"; 
in
{
  programs.plasma = {
    enable = true;

    # Add Virtual Desktops
    kwin = {
      effects.shakeCursor.enable = true;
      virtualDesktops = {
        animation = "slide";
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
      colorScheme = "Catppuccin${themeFlavour}${themeAccent}";
      cursorTheme = "Catppuccin-${cursorFlavour}-${themeAccent}-Cursors";
      wallpaper = /etc/wallpaper/catppuccin-${lib.strings.toLower themeCfg.flavour}.jpg;
    };

    hotkeys.commands."Launch-Konsole" = {
      key = "Ctrl+T";
      command = "konsole";
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
                launchers = [
                  "applications:org.kde.dolphin.desktop"
                  "preferred://browser"
                  "applications:com.valvesoftware.Steam.desktop"
                  "applications:net.lutris.Lutris.desktop"
                ];
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
                rangeTo = range;
                rangeAuto = "false";
              };
            };
          }
          ( if !issrv-nixostest then {
            name = "org.kde.plasma.systemmonitor";
            config = {
              Sensors = {
                highPrioritySensorIds = ''[\"gpu/all/usage\"]'';
                totalSensors = ''[\"gpu/all/usage\"]'';
              };
            };
          } else "" )
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
}
