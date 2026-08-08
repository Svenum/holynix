{ config, ... }:

let
  authorizedKeys = [
    "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDGEUe5V5fMgoSTe1kWfi8OxNhxuYIcd35gIp6Zxzkrv"
  ];
in
{
  imports = [
    ./hardware.nix
  ];

  holynix = {
    shell.zsh.enable = true;
    locale.name = "en_DE";
    systemType = {
      vm.enable = true;
      server.enable = true;
    };
    users = {
      "sudouser" = {
        isSudoUser = true;
        inherit authorizedKeys;
      };
      "kube" = {
        isSudoUser = false;
        inherit authorizedKeys;
      };
    };
    tools = {
      cliTools.enable = true;
    };

    sops = {
      enableHostKey = true;
      defaultSopsFile = ../../../secrets/kube.yaml;
    };

    virtualisation.k3s = {
      enable = true;
      clusterCIDR = "10.11.0.0/16";
      tokenFile = config.sops.secrets."kube_token".path;
      serverAddress = "https://10.10.0.11:6443";
    };

    network.enable = true;
  };

  # Initial Secrets
  sops.secrets."kube_token".restartUnits = [ "k3s.service" ];
}
