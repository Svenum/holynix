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
  networking = {
    bridges.br0.interfaces = [
      "enp0s31f6"
    ];
    interfaces = {
      "br0" = {
        ipv4 = {
          addresses = [
            {
              address = "172.16.0.14";
              prefixLength = 24;
            }
          ];
          routes = [
            {
              address = "0.0.0.0";
              prefixLength = 0;
              via = "172.16.0.1";
              options.metric = "1";
            }
            {
              address = "172.16.0.0";
              prefixLength = 24;
              via = "172.16.0.1";
              options.metric = "1";
            }
          ];
        };
      };
      "shim-br0" = {
        ipv4 = {
          addresses = [
            {
              address = "172.16.0.14";
              prefixLength = 24;
            }
          ];
          routes = [
            {
              address = "172.16.0.0";
              prefixLength = 24;
              via = "172.16.0.1";
              options.metric = "0";
            }
          ];
        };
      };
    };
    defaultGateway = {
      address = "172.16.0.1";
      interface = "shim-br0";
      source = "172.16.0.14";
      metric = 0;
    };
    nameservers = [
      "172.16.0.3"
      "172.16.0.4"
    ];
    useDHCP = false;
    macvlans.shim-br0 = {
      mode = "bridge";
      interface = "enp0s31f6";
    };
  };
}
