{ pkgs, lib, config, modulesPath, ... }:

let
  ip = "172.20.0.214";
in
{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    ./hardware.nix
  ];

  holynix = {
    shell.zsh.enable = true;
    locale.name = "en_DE";
    systemType = {
      vm.enable = true;
      server = {
        enable = true;
        ansibleTarget = true;
      };
    };
    users = {
      "sudouser" = {
        isGuiUser = true;
        isSudoUser = true;
        isDockerUser = true;
        uid = 1000;
        initialPassword = "test123";
        authorizedKeys = [
          "ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBABz8jUkUacu8PahA+mlDCCp3780yrcpAcNZIJ1CFswAbgbWoK+FZxdQ3P43X4cBjKVtz8tthf4xHhkGe6eNC1+ofgHq5bXfIP15ba7AEncdUvreQzPx2Aao7yZFw94piTiZqlQA193SZTw8ggbYPwn3hnXkFT/6ttIEr+18xUMGFM9c1A=="
        ];
      };
    };
    tools = {
      cliTools.enable = true;
    };
    network.enable = true;
    virtualisation.docker.enable = true;
  };
  
  networking = {
    bridges.br0.interfaces = [
      "ens3"
    ];
    interfaces = {
      "br0" = {
        ipv4.addresses = [{
          address = ip;
          prefixLength = 24;
        }];
        useDHCP = false;
      };
      "ens3".useDHCP = true;
    };
    defaultGateway = "172.20.0.1";
    nameservers = [ "9.9.9.9" "1.1.1.1" ];
  };
}
