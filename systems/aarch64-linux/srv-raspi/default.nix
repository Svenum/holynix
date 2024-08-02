{ pkgs, ... }:

{
  imports = [ ./hardware.nix ];

  holynix = {
    boot.enable = false;
    shell.zsh.enable = true;
    locale.name = "en_DE";
    tools = {
      nvim.enable = true;
      tmux.enable = true;
      cliTools.enable = true;
    };
    network.enable = true;
    users =  {
      "sudouser" = {
        isGuiUser = true;
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
    interfaces = {
      enp1s0.ipv4.addresses = [{
        address = "172.16.0.12";
        prefixLength = 24;
      }];
    };
    defaultGateway = "172.16.0.1";
    nameservers = [ "172.16.0.3" "172.16.0.4" ];
    useDHCP = false;
  };

# SSH
  services.openssh.enable = true;
}
