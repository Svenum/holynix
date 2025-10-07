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
