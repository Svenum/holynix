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
        authorizedKeys = authorizedKeys;
      };
      "kube" = {
        isSudoUser = false;
        authorizedKeys = authorizedKeys;
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
      initSecrets = [ "kube_token" ];
    };

    network.enable = true;

    virtualisation.k3s = {
      enable = true;
      clusterCIDR = "10.11.0.0/16";
      tokenFile = config.sops.secrets."kube_token".path;
    };
  };

  # Initial Secrets
  sops.secrets."kube_token".restartUnits = [ "k3s.service" ];
}
