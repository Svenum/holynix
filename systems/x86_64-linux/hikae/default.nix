{ modulesPath, pkgs, ... }:
let
  myKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDGEUe5V5fMgoSTe1kWfi8OxNhxuYIcd35gIp6Zxzkrv";
  backupKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA6e76JnGQ4eJUVT4RYwlTIY+2LaCjkAmia1WMJJXCwh";
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
      "backup".authorizedKeys = [ backupKey ];
    };
    tools.cliTools.enable = true;
    services.tailscale = {
      enable = true;
      advertiseExitNode = false;
    };
    sops = {
      defaultSopsFile = ../../../secrets/hikae/default.yaml;
      enableHostKey = true;
    };
  };

  networking.hostId = "9a95d7e7";

  environment.systemPackages = [ pkgs.mbuffer ];
}
