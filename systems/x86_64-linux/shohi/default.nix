{ modulesPath, ... }:
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
        password = "shohi";
        authorizedKeys = [
          myKey
        ];
      };
    };
    tools.cliTools.enable = true;
    services = {
      publicDomain = "holypenguin.net";
      caddy.enableSSL = false;
      pelican = {
        enable = true;
        oauth.enable = false;
      };
    };
    sops = {
      defaultSopsFile = ../../../secrets/shohi/default.yaml;
      enableHostKey = true;
    };
  };

  networking.hostId = "9a95d7e6";
}
