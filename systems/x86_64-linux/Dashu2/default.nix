{ config, ... }:

let
  authorizedKeys = [
    "ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBABz8jUkUacu8PahA+mlDCCp3780yrcpAcNZIJ1CFswAbgbWoK+FZxdQ3P43X4cBjKVtz8tthf4xHhkGe6eNC1+ofgHq5bXfIP15ba7AEncdUvreQzPx2Aao7yZFw94piTiZqlQA193SZTw8ggbYPwn3hnXkFT/6ttIEr+18xUMGFM9c1A=="
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
        initialPassword = "Dashu";
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
      defaultSopsFile = ../../../secrets/Dashu.yaml;
    };

    virtualisation.k3s = {
      enable = true;
      clusterCIDR = "10.11.0.0/16";
      tokenFile = config.sops.secrets."kube_token".path;
      serverAddr = "https://172.16.0.31:6443";
    };

    network.enable = true;
  };

  # Initial Secrets
  sops.secrets."kube_token".restartUnits = [ "k3s.service" ];

  networking = {
    interfaces.enp1s0.ipv4.addresses = [
      {
        address = "172.16.0.32";
        prefixLength = 24;
      }
    ];
    defaultGateway = "172.16.0.1";
    nameservers = [
      "172.16.0.3"
      "172.16.0.4"
    ];
  };
}
