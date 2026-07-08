{
  pkgs,
  config,
  lib,
  ...
}:

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
    services.tailscale = {
      enable = true;
      useAuthKeyFile = false;
      acceptDNS = true;
    };
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

  powerManagement.powertop = {
    enable = true;
    postStart = ''
      ${lib.getExe' config.systemd.package "udevadm"} trigger -c bind -s usb -a idVendor=32ac -a idProduct=0014
      ${lib.getExe' config.systemd.package "udevadm"} trigger -c bind -s usb -a idVendor=32ac -a idProduct=0018
      ${lib.getExe' config.systemd.package "udevadm"} trigger -c bind -s usb -a idVendor=2b89 -a idProduct=0043
    '';
  };

  environment.variables = {
    # Needed to fix Kwin if gpu gets detatched
    KWIN_DRM_DEVICES = "/dev/dri/card1";
    KWIN_USE_OVERLAYS = "1";
  };

  # Hosts
  networking.networkmanager.dns = "dnsmasq";
  environment.etc."NetworkManager/dnsmasq.d/kaeru.conf".text = ''
    address=/kaeru.holypenguin.net/192.168.122.128
  '';

  # ld
  programs.nix-ld = {
    enable = true;
    libraries = with pkgs; [
      stdenv.cc.cc.lib
    ];
  };

}
