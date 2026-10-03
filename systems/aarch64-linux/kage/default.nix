{ lib, ... }:
let
  ip = "172.16.0.13";
in
{
  imports = [ ./hardware.nix ];

  holynix = {
    boot.enable = false;
    shell.zsh.enable = true;
    locale.name = "en_DE";
    systemType.server.enable = true;
    tools.cliTools.enable = true;
    network = {
      enable = true;
      useIWD = false;
    };
    users = {
      "holynix" = {
        isSudoUser = true;
        initialPassword = "test123";
        uid = 1000;
        authorizedKeys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDGEUe5V5fMgoSTe1kWfi8OxNhxuYIcd35gIp6Zxzkrv"
        ];
      };
    };
    services = {
      publicDomain = "holypenguin.net";
      listeningIp = ip;
      adguard = {
        enable = true;
        dnsHosts = [ ip ];
      };
      prometheus.enable = true;
      tailscale = {
        enable = true;
        advertiseRoutes = [
          "172.16.0.0/24"
          "172.18.0.0/24"
        ];
      };
    };
    sops = {
      defaultSopsFile = ../../../secrets/kage/default.yaml;
      enableHostKey = true;
    };
  };

  networking = {
    hostId = "5a1254f4";
    bridges.br0.interfaces = [ "end0" ];
    interfaces = {
      enp38s0.ipv4.addresses = lib.mkForce [ ];
      br0.ipv4.addresses = [
        {
          address = ip;
          prefixLength = 24;
        }
      ];
    };
    defaultGateway = "172.16.0.1";
    nameservers = [
      "127.0.0.1"
      "172.16.0.11"
      "1.1.1.1"
      "8.8.8.8"
    ];
  };
}
