{ ... }:
{
  imports = [
    ./configuration.nix
  ];

  holynix = {
    systemType = {
      cloud.enable = true;
      server = {
        enable = true;
        ansibleTarget = true;
      };
    };
    tools = {
      nvim.enable = true;
      tmux.enable = true;
      cliTools.enable = true;
    };
    shell.zsh.enable = true;
    boot.enable = true;
    local.name = "en_DE";
    network.enable = true;
    users =  {
      "root" = {
        authorizedKeys = [
          "ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBABz8jUkUacu8PahA+mlDCCp3780yrcpAcNZIJ1CFswAbgbWoK+FZxdQ3P43X4cBjKVtz8tthf4xHhkGe6eNC1+ofgHq5bXfIP15ba7AEncdUvreQzPx2Aao7yZFw94piTiZqlQA193SZTw8ggbYPwn3hnXkFT/6ttIEr+18xUMGFM9c1A=="
        ];
      };
      "sudouser" = {
        isSudoUser = true;
        initialPassword = "test123";
        uid = 1000;
        authorizedKeys = [
          "ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBABz8jUkUacu8PahA+mlDCCp3780yrcpAcNZIJ1CFswAbgbWoK+FZxdQ3P43X4cBjKVtz8tthf4xHhkGe6eNC1+ofgHq5bXfIP15ba7AEncdUvreQzPx2Aao7yZFw94piTiZqlQA193SZTw8ggbYPwn3hnXkFT/6ttIEr+18xUMGFM9c1A=="
        ];
      };
    };
  };

  networking = {
    defaultGateway = "x.x.x.x";
    nameservers = [ "9.9.9.9" "149.112.112.112" ];
    useDHCP = false;
    interfaces.eth0 = {
      ipAddress = "y.y.y.y";
      prefixLength = 24;
    };
  };
}
