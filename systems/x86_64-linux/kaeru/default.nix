{ config, ... }:
let
  myKey = "ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBABz8jUkUacu8PahA+mlDCCp3780yrcpAcNZIJ1CFswAbgbWoK+FZxdQ3P43X4cBjKVtz8tthf4xHhkGe6eNC1+ofgHq5bXfIP15ba7AEncdUvreQzPx2Aao7yZFw94piTiZqlQA193SZTw8ggbYPwn3hnXkFT/6ttIEr+18xUMGFM9c1A==";
  ipDMZ = "172.16.0.150";
  ipIoT = "172.18.0.150";

  cfgS = config.holynix.services;
  cfgC = config.holynix.services.cloudflared;
in
{
  imports = [
    ./hardware.nix
    ./disko.nix
    ./zfs.nix
    ./kvm.nix
  ];

  holynix = {
    shell.zsh.enable = true;
    locale.name = "en_DE";
    systemType = {
      vm.enable = true;
      server = {
        enable = true;
        zfsSshDecryption = {
          enable = true;
          authorizedKeys = [ myKey ];
        };
      };
    };
    users = {
      "holyadmin" = {
        isSudoUser = true;
        isKvmUser = true;
        password = "";
        authorizedKeys = [
          myKey
        ];
      };
      "sven".authorizedKeys = [ myKey ];
      "martin" = { };
      "rick" = { };
      "carmen" = { };
      "zoe" = { };
      "podman" = {
        password = "podman";
        authorizedKeys = [
          myKey
        ];
      };
    };
    tools.cliTools.enable = true;
    hardware.gpu.nvidia = {
      enable = true;
      packageChannel = "legacy_580";
    };
    services = {
      publicDomain = "holypenguin.net";
      listeningIp = ipDMZ;
      vaultwarden.enable = true;
      adguard = {
        enable = true;
        dnsHosts = [
          ipDMZ
          ipIoT
        ];
      };
      authentik.enable = true;
      jellyfin.enable = true;
      prometheus.enable = true;
      stirlingpdf.enable = true;
      it-tools.enable = true;
      grafana = {
        enable = true;
        smtp.host = "smtp.zoho.eu:465";
        oauth = {
          auth_url = "https://authentik.holypenguin.net/application/o/authorize/";
          token_url = "https://authentik.holypenguin.net/application/o/token/";
          api_url = "https://authentik.holypenguin.net/application/o/userinfo/";
          signout_redirect_url = "https://authentik.holypenguin.net/application/o/grafana/end-session/";
        };
      };
      ups.enable = true;
      nextcloud = {
        enable = true;
        ldap = {
          enable = true;
          host = "ldaps://authentik.holypenguin.net";
          bindDN = "cn=sa-nextcloud,ou=users,dc=nextcloud,dc=holypenguin,dc=net";
          dn = "dc=nextcloud,dc=holypenguin,dc=net";
          groupFilter = "Family;Share";
          loginFilter = "(&(&(objectClass=user)(memberof=cn=Nextcloud,ou=groups,dc=nextcloud,dc=holypenguin,dc=net))(|(uid=%uid)(|(mailPrimaryAddress=%uid)(mail=%uid))(|(cn=%uid)(displayName=%uid)(mail=%uid))))";
          userFilter = "(&(objectClass=user)(memberof=cn=Nextcloud,ou=groups,dc=nextcloud,dc=holypenguin,dc=net))";
        };
      };
      collabora.enable = true;
      paperless = {
        enable = true;
        enableOidc = true;
      };
      protonbridge.enable = true;
      cloudflare-ddns.enable = true;
      cloudflared = {
        enable = true;
        tunnelId = "f9822e76-cf75-43fa-b340-00092f5f53b3";
      };
      tailscale = {
        enable = true;
        advertiseRoutes = [ "172.16.0.0/24" ];
      };
      immich = {
        enable = true;
        oauth = {
          enable = true;
          issuerUrl = "https://authentik.holypenguin.net/application/o/immich/.well-known/openid-configuration";
        };
      };
      restic = {
        enable = true;
        proxyAuth.enable = true;
      };
      kanbn.enable = true;
      samba = {
        enable = true;
        userShares = [
          "sven"
          "martin"
          "carmen"
          "zoe"
          "rick"
        ];
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
    hostId = "f488d788";
    vlans = {
      "enp0s31f6.180" = {
        id = 180;
        interface = "enp0s31f6";
      };
    };
    bridges = {
      br0.interfaces = [ "enp0s31f6" ];
      "br0.180".interfaces = [ "enp0s31f6.180" ];
    };
    interfaces = {
      "br0.180".ipv4.addresses = [
        {
          address = ipIoT;
          prefixLength = 24;
        }
      ];
      br0.ipv4.addresses = [
        {
          address = ipDMZ;
          prefixLength = 24;
        }
      ];
    };
    defaultGateway = "172.16.0.1";
    nameservers = [
      "127.0.0.1"
      "172.16.0.4"
      "1.1.1.1"
      "8.8.8.8"
    ];
  };

  services = {
    cloudflared.tunnels."${cfgC.tunnelId}".ingress."homeassistant.${cfgS.publicDomain}" =
      "https://homeassistant.${cfgS.privateDomain}";
    caddy = {
      enable = true;
      virtualHosts."homeassistant.${cfgS.publicDomain}" = {
        serverAliases = [ "homeassistant.${cfgS.privateDomain}" ];
        extraConfig = ''
          reverse_proxy 172.16.0.151:8123
        '';
      };
    };
  };

  boot = {
    binfmt.emulatedSystems = [ "aarch64-linux" ];
    initrd.systemd.network = {
      enable = true;
      networks."10-enp0s31f6" = {
        matchConfig.Name = "enp0s31f6";
        address = [ "${ipDMZ}/24" ];
        gateway = [ "172.16.0.1" ];
        linkConfig.RequiredForOnline = "routable";
      };
    };
  };
}
