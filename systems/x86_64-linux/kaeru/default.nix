{ modulesPath, config, ... }:

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
      server.enable = true;
    };
    users = {
      "holyadmin" = {
        isSudoUser = true;
        password = "";
        authorizedKeys = [
          "ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBABz8jUkUacu8PahA+mlDCCp3780yrcpAcNZIJ1CFswAbgbWoK+FZxdQ3P43X4cBjKVtz8tthf4xHhkGe6eNC1+ofgHq5bXfIP15ba7AEncdUvreQzPx2Aao7yZFw94piTiZqlQA193SZTw8ggbYPwn3hnXkFT/6ttIEr+18xUMGFM9c1A=="
        ];
      };
    };
    tools.cliTools.enable = true;

    services = {
      publicDomain = "holypenguin.net";
      vaultwarden = {
        enable = true;
        environmentFile = [
          config.sops.secrets."services/vaultwarden/config".path
        ];
      };
    };

    sops = {
      defaultSopsFile = ../../../secrets/kaeru/default.yaml;
      enableHostKey = true;
    };
  };

  networking = {
    hosts."127.0.0.1" = [
      "vaultwarden.kaeru.holypenguin.net"
      "nextcloud.kaeru.holypenguin.net"
      "authentik.kaeru.holypenguin.net"
      "pelican.kaeru.holypenguin.net"
      "grafana.kaeru.holypenguin.net"
    ];
    interfaces.enp1s0.ipv4.addresses = [
      {
        address = "192.168.122.128";
        prefixLength = 24;
      }
    ];
    defaultGateway = "192.168.122.1";
    nameservers = [
      "1.1.1.1"
      "8.8.8.8"
    ];
  };
  services.qemuGuest.enable = true;
  boot.binfmt.emulatedSystems = [ "aarch64-linux" ];

  virtualisation.vmVariant.virtualisation = {
    memorySize = 4096;
    cores = 4;
  };
}
