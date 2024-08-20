{ lib, config, pkgs, ... }:

{
  # Import Modules
  imports = [ ./hardware.nix ];

  holynix = {
    desktop.plasma.enable = true;
    locale.name = "de_DE";
    theme = {
      accent = "peach";
      flavour = "mocha";
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
          "ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBABz8jUkUacu8PahA+mlDCCp3780yrcpAcNZIJ1CFswAbgbWoK+FZxdQ3P43X4cBjKVtz8tthf4xHhkGe6eNC1+ofgHq5bXfIP15ba7AEncdUvreQzPx2Aao7yZFw94piTiZqlQA193SZTw8ggbYPwn3hnXkFT/6ttIEr+18xUMGFM9c1A== sven@Ni"
        ];
      };
    };

    shell.zsh.enable = true;
    tools = {
      nvim.enable = true;
      tmux.enable = true;
      flatpak.enable = true;
      cliTools.enable = true;
    };
    virtualisation.kvm.enable = true;
    gpu.nvidia.enable = true;

    network.enable = true;

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

    # Open firewall for the AusweisApp
    firewall.ausweisapp.open = true;
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
