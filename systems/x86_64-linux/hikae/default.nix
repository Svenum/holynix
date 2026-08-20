{
  config,
  lib,
  modulesPath,
  pkgs,
  ...
}:
let
  myKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDGEUe5V5fMgoSTe1kWfi8OxNhxuYIcd35gIp6Zxzkrv";
in
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    ./disko.nix
  ];

  holynix = {
    shell.zsh.enable = true;
    locale.name = "en_DE";
    systemType = {
      vm.enable = true;
      server.enable = true;
    };
    users = {
      "holyadmin" = {
        isSudoUser = true;
        isKvmUser = true;
        password = "";
        authorizedKeys = [
          myKey
        ];
      };
      "backup".authorizedKeys = [ myKey ];
    };
    tools.cliTools.enable = true;
    services = {
      tailscale = {
        enable = true;
        advertiseRoutes = [ "172.16.0.0/24" ];
      };
    };

    sops = {
      defaultSopsFile = ../../../secrets/kaeru/default.yaml;
      enableHostKey = true;
    };
  };

  networking.hostId = "9a95d7e7";

  environment.systemPackages = [ pkgs.mbuffer ];
}
