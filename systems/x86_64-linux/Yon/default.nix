{ pkgs, lib, config, ... }:

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
    hardware.laptop.enable = true;
    users."sven" = {
      isGuiUser = true;
      isSudoUser = true;
      isKvmUser = true;
      git = {
        userName = "Svenum";
        userEmail = "s.ziegler@holypenguin.net";
      };
    };
    wireguard = {
      enable = true;
      interfaces = {
        "wg-home" = "${config.sops.secrets."wg_home".path}";
        "wg-nl" = "${config.sops.secrets."wg_nl".path}";
      };
    };
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

    sops = {
      enableHostKey = true;
      defaultSopsFile = ../../../secrets/wireguard.yaml;
    };
  };
  # Force linux kernel 6.9 to build failure in kvmfr
  boot.kernelPackages = pkgs.linuxKernel.packages.linux_6_9;

  # Enable fw-fanctrl
  programs.fw-fanctrl = {
    enable = true;
  };

  # enable Steam input
  hardware.steam-hardware.enable = true;
  programs.gamescope.enable = true;

  # enable solaar
  services.solaar = {
    enable = true;
    window = "hide";
    extraArgs = "--restart-on-wake-up";
  };
  
  # Enable Waydroid
  virtualisation.waydroid.enable = true;

  # enable aarch64 emulation
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  environment.systemPackages = with pkgs; [
    holynix.tetris
  ];

  # Enable OpenSSH for hostkeys but disable firewall
  services.openssh = {
    enable = true;
    openFirewall = false;
  };

  # Restart Wiregaurd on secret change
  sops.secrets."wg_home".restartUnits = [ "wg-quick-wg-nl.service" ];
  sops.secrets."wg_nl".restartUnits = [ "wg-quick-wg-nl.service" ];
}
