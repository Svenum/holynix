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

  systemd.network = {
    enable = true;
    networks = {
      "10-enp0s31f6" = {
        matchConfig.Name = "enp0s31f6";
        address = [ "172.16.0.14/24" ];
        dns = [
          "172.16.0.3"
          "172.16.0.4"
        ];
        routes = [
          {
            Gateway = "172.16.0.1";
            Metric = 1;
            Destination = "0.0.0.0/0";
          }
          {
            Gateway = "172.16.0.1";
            Metric = 1;
            Destination = "172.16.0.0/24";
          }
        ];
      };
      "20-shim" = {
        matchConfig.Name = "shim";
        address = [ "172.16.0.14/24" ];
        dns = [
          "172.16.0.3"
          "172.16.0.4"
        ];
        routes = [
          {
            Gateway = "172.16.0.1";
            Metric = 0;
            Destination = "0.0.0.0/0";
          }
          {
            Gateway = "172.16.0.1";
            Metric = 0;
            Destination = "172.16.0.0/24";
          }
        ];
      };
    };
    netdevs."20-shim" = {
      netdevConfig = {
        Kind = "ipvlan";
        Name = "shim";
      };
      ipvlanConfig = {
        mode = "L2";
        flag = "bridge";
      };
    };
  };
}
