{ pkgs, ... }:

{
  imports = [ ./hardware.nix ];

  holynix = {
    boot.systemdBoot = false;
    shell.zsh.enable = true;
    locale.name = "en_DE";
    tools = {
      nvim.enable = true;
      tmux.enable = true;
      cliTools.enable = true;
    };
  };

  networking = {
    interfaces = {
      enp1s0.ipv4.addresses = [{
        address = "172.16.0.12";
        prefixLength = 24;
      }];
    };
    defaultGateway = "172.16.0.1";
    nameservers = [ "172.16.0.3" "172.16.0.4" ];
    useDHCP = false;
  };

  hardware = {
    deviceTree = {
      enable = true;
      filter = "*rpi-4-*.dtb";
    };
  };
  console.enable = false;
  environment.systemPackages = with pkgs; [
    libraspberrypi
    raspberrypi-eeprom
  ];
}
