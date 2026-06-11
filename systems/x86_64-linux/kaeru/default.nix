{ modulesPath, config, ... }:

let
  myKey = "ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBABz8jUkUacu8PahA+mlDCCp3780yrcpAcNZIJ1CFswAbgbWoK+FZxdQ3P43X4cBjKVtz8tthf4xHhkGe6eNC1+ofgHq5bXfIP15ba7AEncdUvreQzPx2Aao7yZFw94piTiZqlQA193SZTw8ggbYPwn3hnXkFT/6ttIEr+18xUMGFM9c1A==";
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
      server.enable = true;
    };
    users = {
      "holyadmin" = {
        isSudoUser = true;
        password = "";
        authorizedKeys = [
          myKey
        ];
      };
      "podman" = {
        isSudoUser = false;
        password = "podman";
        authorizedKeys = [
          myKey
        ];
      };
    };
    tools.cliTools.enable = true;

    services = {
      publicDomain = "holypenguin.net";
      listeningIp = (builtins.head config.networking.interfaces.enp1s0.ipv4.addresses).address;
      vaultwarden.enable = true;
      adguard.enable = true;
      authentik.enable = true;
      nextcloud = {
        enable = true;
        ldap = {
          enable = true;
          host = "ldaps://authentik.holypenguin.net";
          bindDN = "cn=sa-nextcloud,ou=users,dc=nextcloud,dc=holypenguin,dc=net";
          dn = "dc=nextcloud,dc=holypenguin,dc=net";
          groupFilter = "(&(|(objectclass=group))(|(cn=Family)(cn=Holypenguin)(cn=Media)(cn=Share)))";
          loginFilter = "(&(&(objectClass=user)(memberof=cn=Nextcloud,ou=groups,dc=nextcloud,dc=holypenguin,dc=net))(|(uid=%uid)(|(mailPrimaryAddress=%uid)(mail=%uid))(|(cn=%uid)(displayName=%uid)(mail=%uid))))";
          userFilter = "(&(objectClass=user)(memberof=cn=Nextcloud,ou=groups,dc=nextcloud,dc=holypenguin,dc=net))";
        };
      };
      paperless = {
        enable = false;
        enableOidc = true;
      };
    };

    virtualisation = {
      podman.enable = true;
      kvm.enable = true;
    };

    sops = {
      defaultSopsFile = ../../../secrets/kaeru/default.yaml;
      enableHostKey = true;
    };
  };

  networking = {
    interfaces.enp1s0.ipv4.addresses = [
      {
        address = "192.168.122.128";
        prefixLength = 24;
      }
    ];
    defaultGateway = "192.168.122.1";
    nameservers = [
      "172.16.0.3"
      "172.16.0.4"
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
