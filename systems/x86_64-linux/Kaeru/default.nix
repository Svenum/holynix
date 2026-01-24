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
    services.nextcloud.enable = true;
    boot = {
      memtest = true;
      uefi-shell = true;
    };
    shell.zsh.enable = true;
    locale.name = "en_DE";
    systemType.server = {
      enable = true;
      zfs = {
        enable = true;
        hostId = "1b6c3a18";
        snapshots = [
          {
            dataset = "kaeru/storage";
            frequenz = "medium";
          }
          {
            dataset = "kaeru/container";
            frequenz = "high";
          }
          {
            dataset = "kaeru/vms";
            frequenz = "low";
          }
          {
            dataset = "kaeru/media";
            frequenz = "very_low";
          }
        ];
      };
    };
    sops = {
      defaultSopsFile = ../../../secrets/kaeru.yaml;
      enableHostKey = true;
    };
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
      podman = {
        enable = true;
        bridges = [
          {
            name = "br0";
            interface = "enp0s31f6";
            address = "172.16.0.14";
            prefixLength = 24;
            dns = [
              "172.16.0.3"
              "172.16.0.4"
            ];
            gateway = "172.16.0.1";
          }
        ];
      };
      kvm.enable = true;
    };
    gpu.nvidia.enable = true;
  };
}
