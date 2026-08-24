{ ... }:

{
  # Import Modules
  imports = [ ./hardware.nix ];

  holynix = {
    desktop.plasma.enable = true;
    theme = {
      accent = "red";
      flavor = "latte";
    };

    users = {
      "carmen" = {
        isGuiUser = true;
        isSudoUser = false;
      };
      "sudouser" = {
        isGuiUser = true;
        isSudoUser = true;
        authorizedKeys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDGEUe5V5fMgoSTe1kWfi8OxNhxuYIcd35gIp6Zxzkrv"
        ];
      };
    };

    shell.zsh.enable = true;
    systemType.laptop.enable = true;
    tools = {
      flatpak.enable = true;
      cliTools.enable = true;
    };

    network.enable = true;
    firewall.ausweisapp.open = true;
    bluetooth.enable = true;

    powerManagement.enable = true;

    hardware = {
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
    sops = {
      defaultSopsFile = ../../../secrets/PC-Carmen/default.yaml;
      enableHostKey = true;
    };
    services.tailscale.enable = true;
  };

  services = {
    # enable solaar
    solaar = {
      enable = true;
      window = "hide";
      extraArgs = "--restart-on-wake-up";
    };
    # Enable ssh
    openssh.enable = true;

    # Enable fwupd
    fwupd.enable = true;
  };
}
