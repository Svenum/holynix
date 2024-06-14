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

    network.enable = true;
  };

  # Enable SSH
  services.openssh.enable = true;

  # Sops
  sops.secrets."kube_token" = {};

  # Enable K3S
  services.k3s = {
    enable = true;
    tokenFile = kubeTokenFile;
    extraFlags = "--cluster-cidr ${clusterCIDR}";
    clusterInit = true;
  };

  # Enable Guest Agents
  services.qemuGuest.enable = true;
  services.spice-vdagentd.enable = true;
}