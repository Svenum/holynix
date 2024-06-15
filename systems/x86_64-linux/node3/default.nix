{ config, ... }:

let
  adminUser = {
    name = "sudouser";
    authorizedKeys = [
      "ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBABz8jUkUacu8PahA+mlDCCp3780yrcpAcNZIJ1CFswAbgbWoK+FZxdQ3P43X4cBjKVtz8tthf4xHhkGe6eNC1+ofgHq5bXfIP15ba7AEncdUvreQzPx2Aao7yZFw94piTiZqlQA193SZTw8ggbYPwn3hnXkFT/6ttIEr+18xUMGFM9c1A=="
    ];
  };
  kubeUser = {
    name = "kube";
    authorizedKeys = [
      "ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBABz8jUkUacu8PahA+mlDCCp3780yrcpAcNZIJ1CFswAbgbWoK+FZxdQ3P43X4cBjKVtz8tthf4xHhkGe6eNC1+ofgHq5bXfIP15ba7AEncdUvreQzPx2Aao7yZFw94piTiZqlQA193SZTw8ggbYPwn3hnXkFT/6ttIEr+18xUMGFM9c1A=="
    ];
  };
  clusterCIDR = "10.11.0.0/16";
  kubeTokenFile = config.sops.secrets."kube_token".path;
in
{
  imports = [
    ./hardware.nix
  ];

  holynix = {
    shell.zsh.enable = true;
    locale.name = "en_DE";
    users = {
      "${adminUser.name}" = {
        isSudoUser = true;
        authorizedKeys = adminUser.authorizedKeys;
      };
      "${kubeUser.name}" = {
        isSudoUser = false;
        authorizedKeys = kubeUser.authorizedKeys;
      };
    };
    tools = {
      nvim.enable = true;
      tmux.enable = true;
      cliTools.enable = true;
    };

    sops = {
      enableHostKey = true;
      defaultSopsFile = ../../../secrets/kube.yaml;
    };

    k3s = {
      enable = true;
      clusterCIDR = "10.11.0.0/16";
      tokenFile = config.sops.secrets."kube_token".path;
      serverAddress = "https://10.10.0.11:6443";
    };

    network.enable = true;
  };

  # Enable SSH
  services.openssh.enable = true;

  # Initial Secrets
  sops.secrets."kube_token".restartUnits = [ "k3s.service" ];
  
  # Enable Guest Agents
  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;
}
