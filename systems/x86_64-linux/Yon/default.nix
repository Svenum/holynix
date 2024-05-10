{ pkgs, lib, config, ... }:

{
  imports = [
    ./hardware.nix
    ./kvm.nix
  ];

  holynix = {
    boot.secureBoot = true;
    desktop.plasma.enable = true;
    shell.zsh.enable = true;
    locale.name = "en_DE";
    users."sven" = {
      isGuiUser = true;
      isSudoUser = true;
      isKvmUser = true;
      git = {
        userName = "Svenum";
        userEmail = "s.ziegler@holypenguin.net";
      };
    };
    wireguard.enable = true;
    tools = {
      nvim.enable = true;
      tmux.enable = true;
      flatpak.enable = true;
      cliTools.enable = true;
      flake.enable = true;
    };

    bluetooth.enable = true;
    network.enable = true;

    kvm = {
      enable = true;
      vfioPCIDevices = [
        "1002:ab30"
        "1002:7480"
      ];
    };

    gpu.amd.enable = true;

    powerManagement.enable = true;

    scanner.enable = true;
    printer = {
      enable = true;
      defaultPrinter = "Epson_ET-2720-Series";
      printers = [ 
        {
          name = "Epson_ET-2720-Series";
          deviceUri = "https://pr-epson.intra.holypenguin.net:631/ipp/print";
          description = "Epson ET-2720"; 
          model = "epson-inkjet-printer-escpr/Epson-ET-2720_Series-epson-escpr-en.ppd";
        }
        {
          name = "HP_Officejet_5740-Series";
          deviceUri = "https://pr-hp.intra.holypenguin.net/ipp/printers";
          description = "HP Officejet 5740"; 
          model = "HP/hp-officejet_5740_series.ppd.gz";
        }
      ];
    };
  };
  # Enable fw-fanctrl
  programs.fw-fanctrl = {
    enable = true;
    config = {
      defaultStrategy = "lazy";
      strategies = {
        "lazy" = {
          fanSpeedUpdateFrequency = 5;
          movingAverageInterval = 30;
          speedCurve = [
            { temp = 0; speed = 15; }
            { temp = 50; speed = 15; }
            { temp = 65; speed = 25; }
            { temp = 70; speed = 35; }
            { temp = 75; speed = 50; }
            { temp = 85; speed = 100; }
          ];
        };
      };
    };
  };

  # enable Steam input
  hardware.steam-hardware.enable = true;
  programs.gamescope.enable = true;

  # enable solaar
  programs.solaar.enable = true;
  
  # Enable Waydroid
  virtualisation.waydroid.enable = true;

  environment.systemPackages = with pkgs; [
    holynix.tetris
  ];
}
