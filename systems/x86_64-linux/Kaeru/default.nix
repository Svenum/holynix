{ lib, ... }:

let
  containerImports = lib.filter (n: lib.strings.hasSuffix ".nix" n) (
    lib.filesystem.listFilesRecursive ./container
  );
in
{
  imports = [
    ./hardware.nix
    ./smb.nix
  ]
  ++ containerImports;
  holynix = {
    boot = {
      memtest = true;
      uefi-shell = true;
    };
    shell.zsh.enable = true;
    locale.name = "en_DE";
    systemType.server = {
      enable = true;
      enableZfs = true;
    };
    sops.enableHostKey = true;
    users = {
      "sudouser" = {
        isSudoUser = true;
        isKvmUser = true;
        initialPassword = "Kaeru";
        authorizedKeys = [
          "ecdsa-sha2-nistp521 AAAAE2VjZHNhLXNoYTItbmlzdHA1MjEAAAAIbmlzdHA1MjEAAACFBABz8jUkUacu8PahA+mlDCCp3780yrcpAcNZIJ1CFswAbgbWoK+FZxdQ3P43X4cBjKVtz8tthf4xHhkGe6eNC1+ofgHq5bXfIP15ba7AEncdUvreQzPx2Aao7yZFw94piTiZqlQA193SZTw8ggbYPwn3hnXkFT/6ttIEr+18xUMGFM9c1A=="
        ];
      };
    };
    tools.cliTools.enable = true;
    network.enable = true;
    virtualisation = {
      podman.enable = true;
      kvm.enable = true;
    };
    gpu.nvidia.enable = true;
  };

  systemd = {
    services."systemd-networkd".environment.SYSTEMD_LOG_LEVEL = "debug";
    network = {
      enable = true;
      networks = {
        "30-enp0s31f6" = {
          matchConfig.Name = "enp0s31f6";
          networkConfig.Bridge = "br0";
        };

        "40-br0" = {
          matchConfig.Name = "br0";
          addresses = [
            {
              Address = "172.16.0.14/24";
              AddPrefixRoute = "no";
            }
          ];
          networkConfig.IPVLAN = "shim-br0";
          dns = [
            "172.16.0.3"
            "172.16.0.4"
          ];
          routes = [
            {
              Gateway = "172.16.0.1";
              Destination = "0.0.0.0/0";
              Metric = 1;
            }
            {
              Metric = 1;
              Destination = "172.16.0.0/24";
              Scope = "link";
              Source = "172.16.0.14/32";
            }
          ];
        };
        "50-shim-br0" = {
          matchConfig.Name = "shim-br0";
          addresses = [
            {
              Address = "172.16.0.14/24";
              AddPrefixRoute = "no";
            }
          ];
          routes = [
            {
              Gateway = "172.16.0.1";
              Destination = "0.0.0.0/0";
              Metric = 0;
            }
            {
              Destination = "172.16.0.0/24";
              Scope = "link";
              Source = "172.16.0.14/32";
              Metric = 0;
            }
          ];
        };
      };
      netdevs = {
        "10-shim-br0" = {
          netdevConfig = {
            Kind = "ipvlan";
            Name = "shim-br0";
          };
          ipvlanConfig = {
            Mode = "L2";
          };
        };
        "10-br0" = {
          netdevConfig = {
            Kind = "bridge";
            Name = "br0";
          };
        };
      };
    };
  };
}
