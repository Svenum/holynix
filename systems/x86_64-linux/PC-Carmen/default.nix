{ ... }:

{
  # Import Modules
  imports = [ ./hardware.nix ];

  holynix = {
    desktop.plasma.enable = true;
    theme = {
      accent = "red";
      flavour = "latte";
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
          "ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBABz8jUkUacu8PahA+mlDCCp3780yrcpAcNZIJ1CFswAbgbWoK+FZxdQ3P43X4cBjKVtz8tthf4xHhkGe6eNC1+ofgHq5bXfIP15ba7AEncdUvreQzPx2Aao7yZFw94piTiZqlQA193SZTw8ggbYPwn3hnXkFT/6ttIEr+18xUMGFM9c1A=="
        ];
      };
    };

    shell.zsh.enable = true;
    systemType.laptop.enable = true;
    tools = {
      nvim.enable = true;
      tmux.enable = true;
      flatpak.enable = true;
      cliTools.enable = true;
    };

    network.enable = true;
    bluetooth.enable = true;

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

  # enable solaar
  services.solaar = {
    enable = true;
    window = "hide";
    extraArgs = "--restart-on-wake-up";
  };

  # Enable ssh
  services.openssh.enable = true;

  # Enable fwupd
  services.fwupd.enable = true;
}
