{}:

{
  systems.kubeNode = { adminUser, kubeUser, clusterCIDR, serverAddr ? null, tokenFile ? /root/.token }: {
      holynix = {
      shell.zsh.enable = true;
      locale.name = "en_US";
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

      network.enable = true;
    };

    # Enable SSH
    services.openssh.enable = true;

    # Enable K3S
    services.k3s = {
      enable = true;
      tokenFile = tokenFile;
      extraFlags = "--cluster-cidr ${clusterCIDR}";
      clusterInit = true;
      serverAddr = serverAddr;
    };
  };
}
