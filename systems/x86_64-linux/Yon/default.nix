{ pkgs, ... }:

{
  imports = [
    ./hardware.nix
    ./kvm.nix
    ./kernel-patch.nix
  ];

  holynix = {
    boot.secureBoot = true;
    desktop.plasma.enable = true;
    shell.zsh.enable = true;
    locale.name = "en_DE";
    systemType.laptop.enable = true;
    users = {
      "sven" = {
        isGuiUser = true;
        isSudoUser = true;
        isKvmUser = true;
        git = {
          userName = "Svenum";
          userEmail = "s.ziegler@holypenguin.net";
        };
      };
    };
    vpn.tailscale.enable = true;
    tools = {
      flatpak.enable = true;
      cliTools.enable = true;
    };

    bluetooth.enable = true;
    network.enable = true;
    network.useIWD = false;

    virtualisation = {
      podman = {
        enable = true;
        disableAutoStart = true;
      };
      kvm = {
        enable = true;
        vfioPCIDevices = [
          "1002:ab30"
          "1002:7480"
        ];
      };
    };

    #powerManagement.enable = true;

    hardware = {
      headsetcontrol.enable = true;
      gpu.amd.enable = true;
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

    # Open firewall for the AusweisApp
    firewall.ausweisapp.open = true;
  };

  programs = {
    # Enable weylus
    weylus = {
      enable = false;
      openFirewall = true;
      users = [
        "sven"
      ];
    };
  };

  hardware = {
    # enable Steam input
    steam-hardware.enable = true;

    # Framework input modules
    inputmodule.enable = true;

    # enable fw-fanctrl
    fw-fanctrl = {
      enable = true;
      config = {
        defaultStrategy = "lazy";
        strategyOnDischarging = "school";
        strategies = {
          "school" = {
            fanSpeedUpdateFrequency = 5;
            movingAverageInterval = 40;
            speedCurve = [
              {
                temp = 45;
                speed = 0;
              }
              {
                temp = 55;
                speed = 15;
              }
              {
                temp = 65;
                speed = 25;
              }
              {
                temp = 70;
                speed = 35;
              }
              {
                temp = 80;
                speed = 45;
              }
              {
                temp = 90;
                speed = 50;
              }
            ];
          };
        };
      };
    };
  };

  services = {
    # Enable solaar
    solaar = {
      enable = true;
      window = "hide";
      extraArgs = "--restart-on-wake-up";
    };

    # Enable fwupd
    fwupd.enable = true;

    # Enable switcherooControl
    switcherooControl.enable = true;
  };

  powerManagement.powertop.enable = true;

  environment = {
    variables = {
      # Needed to fix Kwin if gpu gets detatched
      KWIN_DRM_DEVICES = "/dev/dri/card1";
      KWIN_USE_OVERLAYS = "1";
    };
    systemPackages = with pkgs; [
      framework-tool
      framework-tool-tui
    ];
  };

  # Enable Waydroid
  #virtualisation.waydroid.enable = true;

  # Enable aarch64 emulation
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  # Enable musnix
  musnix.enable = true;

  # Hosts
  networking.hosts."192.168.122.128" = [
    "vaultwarden.kaeru.holypenguin.net"
    "nextcloud.kaeru.holypenguin.net"
    "authentik.kaeru.holypenguin.net"
    "pelican.kaeru.holypenguin.net"
    "grafana.kaeru.holypenguin.net"
  ];

  # ld
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc.lib
    ];
  };

}
