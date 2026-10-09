{
  config,
  pkgs,
  lib,
  ...
}:
let
  myKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDGEUe5V5fMgoSTe1kWfi8OxNhxuYIcd35gIp6Zxzkrv";
  backupKey = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIA6e76JnGQ4eJUVT4RYwlTIY+2LaCjkAmia1WMJJXCwh";
  ipDMZ = "172.16.0.11";
  ipIoT = "172.18.0.11";

  cfgS = config.holynix.services;
  cfgC = config.holynix.services.cloudflared;
in
{
  imports = [
    ./hardware.nix
    ./disko.nix
    ./zfs.nix
    ./kvm.nix
    ./smb.nix
  ];

  holynix = {
    shell.zsh.enable = true;
    locale.name = "en_DE";
    systemType.server = {
      enable = true;
      zfsSshDecryption = {
        enable = true;
        authorizedKeys = [ myKey ];
      };
    };
    users = {
      "holyadmin" = {
        isSudoUser = true;
        isKvmUser = true;
        initialPassword = "";
        authorizedKeys = [
          myKey
        ];
      };
      "sven".authorizedKeys = [ myKey ];
      "martin" = { };
      "rick" = { };
      "podman" = {
        initialPassword = "podman";
        authorizedKeys = [
          myKey
        ];
      };
      "syncoid".authorizedKeys = [ backupKey ];
      "boerg" = {
        isKvmUser = true;
        initialPassword = "boerg";
        authorizedKeys = [
          "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABgQDhIrnXyYZ63yo/Y2XqiPiQ5uOviP6pVYLxx+Iyuo5DjiGsjR/FOG6wWdeTtlpMbEinqFBtq5d3wGqDtQBak9IDsqJ/u9khT7fsQiykrxIxemSv8bCzvXeh9rnFuAA6cjvPwL9Ie7g38W7GHP5aJjLMx6vUiRHafD+5T37uYK2VUhVG8XTbygS4C+k3DOQ36R+whHoLeu0okFhTt6nu2IX2qx/j8kllOwCVq7AjbPAQJmDPvEOVZONHRDSM0XFEiwkdnF0qwtHGzmYARYhL1Tpp/SuSq7EsJvu0UrYl+hJpV+4VbU08M7YsEEwHAQkolKxgJZf6x/A8cliAIoMnrAoZ0a15/GBgadmuqUy1RkR0Lfr5ta4xEriqeYt+uiaZ84hCSVq+k6MX1P0b23ytqdOJXrvjsasDfPuTojvg+pyylZRj2Fz+MlVM3SnEzfvpKGuY7wbVxtg7kcKdL3wXqJZoUoIYGgr1buxO6iLa2784xfUdSK5iu1YA+B2tpxSxSz8="
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
      iglu.enable = true;
      jellyfin.enable = true;
      prometheus = {
        enable = true;
        extraNodeTargets = [ "100.124.29.97:9100" ];
        extraZFSTargets = [ "100.124.29.97:9134" ];
        extraSystemdTargets = [ "100.124.29.97:9558" ];
        targets.homeassistant = {
          enable = true;
          address = "homeassistant.holypenguin.net";
        };
      };
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
          groupFilter = "Family;Share;Calender";
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
        advertiseRoutes = [
          "172.16.0.0/24"
          "172.18.0.0/24"
        ];
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
      "enp38s0.180" = {
        id = 180;
        interface = "enp38s0";
      };
    };
    bridges = {
      br0.interfaces = [ "enp38s0" ];
      "br0.180".interfaces = [ "enp38s0.180" ];
    };
    interfaces = {
      "br0.180".ipv4.addresses = [
        {
          address = ipIoT;
          prefixLength = 24;
        }
      ];
      enp38s0.ipv4.addresses = lib.mkForce [ ];
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
      "172.16.0.13"
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
    initrd = {
      systemd = {
        network = {
          enable = true;
          networks."10-enp38s0" = {
            matchConfig.Name = "enp38s0";
            address = [ "${ipDMZ}/24" ];
            gateway = [ "172.16.0.1" ];
            linkConfig.RequiredForOnline = "routable";
          };
        };
        services.flush-enp38s0 = {
          wantedBy = [ "initrd-switch-root.target" ];
          before = [ "initrd-switch-root.target" ];
          unitConfig.DefaultDependencies = false;
          serviceConfig.Type = "oneshot";
          path = [ pkgs.iproute2 ];
          script = ''
            ip addr flush dev enp38s0
            ip link set enp38s0 down
          '';
        };
      };
    };
  };
}
