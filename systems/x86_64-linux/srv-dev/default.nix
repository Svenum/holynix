{ modulesPath, ... }:

{
  imports = [
    (modulesPath + "/profiles/qemu-guest.nix")
    ./hardware.nix
  ];

  holynix = {
    desktop.plasma.enable = true;
    shell.zsh.enable = true;
    locale.name = "en_DE";
    systemType = {
      vm.enable = true;
      server.enable = true;
    };
    users = {
      "michi" = {
        isGuiUser = true;
        isSudoUser = false;
        git = {
          userName = "stormfire64";
          userEmail = "springermail@web.de";
        };
      };
      "sven" = {
        isGuiUser = true;
        isSudoUser = false;
        git = {
          userName = "Svenum";
          userEmail = "s.ziegler@holypenguin.net";
        };
        authorizedKeys = [
          "ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBABz8jUkUacu8PahA+mlDCCp3780yrcpAcNZIJ1CFswAbgbWoK+FZxdQ3P43X4cBjKVtz8tthf4xHhkGe6eNC1+ofgHq5bXfIP15ba7AEncdUvreQzPx2Aao7yZFw94piTiZqlQA193SZTw8ggbYPwn3hnXkFT/6ttIEr+18xUMGFM9c1A=="
        ];
      };
      "sudouser" = {
        isGuiUser = true;
        isSudoUser = true;
        uid = 1000;
        authorizedKeys = [
          "ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBABz8jUkUacu8PahA+mlDCCp3780yrcpAcNZIJ1CFswAbgbWoK+FZxdQ3P43X4cBjKVtz8tthf4xHhkGe6eNC1+ofgHq5bXfIP15ba7AEncdUvreQzPx2Aao7yZFw94piTiZqlQA193SZTw8ggbYPwn3hnXkFT/6ttIEr+18xUMGFM9c1A=="
        ];
      };
    };
    tools = {
      flatpak.enable = true;
      cliTools.enable = true;
    };
    network.enable = true;
  };

  networking = {
    interfaces = {
      enp1s0.ipv4.addresses = [{
        address = "172.16.0.111";
        prefixLength = 24;
      }];
    };
    defaultGateway = "172.16.0.1";
    nameservers = [ "172.16.0.3" "172.16.0.4" ];
    useDHCP = false;
  };

  # enable aarch64 emulation
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];
}
