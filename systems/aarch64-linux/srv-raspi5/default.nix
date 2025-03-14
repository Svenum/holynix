_:

let
  ip = "172.16.0.13";
in
{
  imports = [ ./hardware.nix ];

  holynix = {
    boot.enable = false;
    shell.zsh.enable = true;
    locale.name = "en_DE";
    systemType.server = {
      enable = true;
      ansibleTarget = true;
    };
    tools = {
      nvim.enable = true;
      tmux.enable = true;
      cliTools.enable = true;
    };
    network = {
      enable = true;
      useIWD = false;
    };
    users = {
      "sudouser" = {
        isSudoUser = true;
        isDockerUser = true;
        initialPassword = "test123";
        uid = 1000;
        authorizedKeys = [
          "ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBABz8jUkUacu8PahA+mlDCCp3780yrcpAcNZIJ1CFswAbgbWoK+FZxdQ3P43X4cBjKVtz8tthf4xHhkGe6eNC1+ofgHq5bXfIP15ba7AEncdUvreQzPx2Aao7yZFw94piTiZqlQA193SZTw8ggbYPwn3hnXkFT/6ttIEr+18xUMGFM9c1A=="
        ];
      };
    };
    virtualisation.docker.enable = true;
  };

  networking = {
    bridges.br0.interfaces = [
      "end0"
    ];
    interfaces = {
      "br0" = {
        ipv4.addresses = [{
          address = ip;
          prefixLength = 24;
        }];
        useDHCP = false;
      };
      "end0".useDHCP = true;
    };
    defaultGateway = "172.16.0.1";
    nameservers = [ "172.16.0.3" "172.16.0.4" ];
    useDHCP = false;
  };
}
