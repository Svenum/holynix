{ pkgs, config, ... }:

{
  imports = [
    ./hardware.nix
    ./kvm.nix
  ];

  holynix = {
    boot = {
      secureBoot = true;
      netboot = true;
      memtest = true;
    };
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
      "boerg" = {
        isGuiUser = false;
        isSudoUser = false;
        isKvmUser = false;
        authorizedKeys = [
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDhIrnXyYZ63yo/Y2XqiPiQ5uOviP6pVYLxx+Iyuo5DjiGsjR/FOG6wWdeTtlpMbEinqFBtq5d3wGqDtQBak9IDsqJ/u9khT7fsQiykrxIxemSv8bCzvXeh9rnFuAA6cjvPwL9Ie7g38W7GHP5aJjLMx6vUiRHafD+5T37uYK2VUhVG8XTbygS4C+k3DOQ36R+whHoLeu0okFhTt6nu2IX2qx/j8kllOwCVq7AjbPAQJmDPvEOVZONHRDSM0XFEiwkdnF0qwtHGzmYARYhL1Tpp/SuSq7EsJvu0UrYl+hJpV+4VbU08M7YsEEwHAQkolKxgJZf6x/A8cliAIoMnrAoZ0a15/GBgadmuqUy1RkR0Lfr5ta4xEriqeYt+uiaZ84hCSVq+k6MX1P0b23ytqdOJXrvjsasDfPuTojvg+pyylZRj2Fz+MlVM3SnEzfvpKGuY7wbVxtg7kcKdL3wXqJZoUoIYGgr1buxO6iLa2784xfUdSK5iu1YA+B2tpxSxSz8= berg@Izanami"
        ];
      };
    };
    vpn = {
      wireguard = {
        enable = true;
        interfaces = {
          "wg-home".configFile = config.sops.secrets."wg_home".path;
          "wg-nl".configFile = config.sops.secrets."wg_nl".path;
        };
      };
      tailscale.enable = true;
    };
    tools = {
      flatpak.enable = true;
      cliTools.enable = true;
      flake.enable = true;
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

    sops = {
      enableHostKey = true;
      defaultSopsFile = ../../../secrets/wireguard.yaml;
    };

    # Open firewall for the AusweisApp
    firewall.ausweisapp.open = true;
  };


  programs = {
    # Enable fw-fanctrl
    fw-fanctrl.enable = true;

    # Enable gamescope
    gamescope.enable = true;
  };

  # enable Steam input
  hardware.steam-hardware.enable = true;

  services = {
    # Enable solaar
    solaar = {
      enable = true;
      window = "hide";
      extraArgs = "--restart-on-wake-up";
    };

    # Enable fwupd
    fwupd.enable = true;

    # Enable OpenSSH for hostkeys but disable firewall
    openssh = {
      enable = true;
      openFirewall = false;
    };
  };

  # Enable Waydroid
  virtualisation.waydroid.enable = true;

  # Enable aarch64 emulation
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  environment.systemPackages = with pkgs; [
    holynix.tetris
  ];


  # Restart Wiregaurd on secret change
  sops.secrets = {
    "wg_home".restartUnits = [ "NetworkManager.service" ];
    "wg_nl".restartUnits = [ "NetworkManager.service" ];
  };
}
