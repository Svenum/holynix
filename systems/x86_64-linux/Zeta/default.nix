{ ... }:

{
  # Import Modules
  imports = [ ./hardware.nix ];

  holynix = {
    desktop.plasma = {
      enable = true;
      krdp.openFirewall = true;
    };
    locale.name = "de_DE";
    theme = {
      accent = "peach";
      flavor = "mocha";
    };

    users = {
      "martinn" = {
        isGuiUser = true;
        isSudoUser = false;
        isKvmUser = true;
        uid = 1001;
      };
      "sumartinn" = {
        isGuiUser = true;
        isSudoUser = true;
        uid = 1000;
        authorizedKeys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDGEUe5V5fMgoSTe1kWfi8OxNhxuYIcd35gIp6Zxzkrv"
        ];
      };
    };

    shell.zsh.enable = true;
    tools = {
      flatpak.enable = true;
      cliTools.enable = true;
    };
    virtualisation.kvm.enable = true;
    hardware = {
      gpu.nvidia = {
        enable = false;
        #packageChanel = "beta";
      };
      scanner.enable = true;
      printer = {
        enable = true;
        defaultPrinter = "Epson_ET-2720-Series";
        discovery = true;
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

    network.enable = true;

    # Open firewall for the AusweisApp
    firewall.ausweisapp.open = true;
    sops = {
      defaultSopsFile = ../../../secrets/Zeta/default.yaml;
      enableHostKey = true;
    };
    services.tailscale.enable = true;
  };
  # enable solaar
  programs.solaar = {
    enable = true;
    userService = {
      enable = true;
      window = "hide";
      extraArgs = [ "--restart-on-wake-up" ];
    };
  };

  services = {
    # Enable ssh
    openssh.enable = true;

    # Enable fwupd
    fwupd.enable = true;
  };
}
