{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
with lib.types;
let
  cfg = config.holynix.systemType.server;
in
{
  options.holynix.systemType.server = {
    enable = mkOption {
      type = bool;
      default = false;
      description = "Enable server specific features";
    };
    ansibleTarget = mkOption {
      type = bool;
      default = false;
      description = "If true everything gets setup to be a ansible target";
    };
    zfsSshDecryption = {
      enable = mkOption {
        type = bool;
        default = false;
        description = "Enable usefull zfs features";
      };
      authorizedKeys = mkOption {
        type = listOf str;
        default = [ ];
        description = "List of keys that are allowed to decrypot pool";
      };
    };

  };
  config = mkIf cfg.enable {
    # Node Exporter
    services.prometheus.exporters.node = {
      enable = true;
      openFirewall = true;
    };

    # zfs
    boot = mkIf cfg.zfsSshDecryption.enable {
      initrd = {

        network.enable = true;

        network.ssh = {
          enable = true;
          port = 2222;
          hostKeys = [
            "/var/ssh/ssh_host_ed25519_key"
          ];
          inherit (cfg.zfsSshDecryption) authorizedKeys;
        };
      };

      systemd.services.zfs-setup-root-profile = {
        description = "Prepare root .profile for ZFS unlocking via SSH";
        wantedBy = [ "initrd.target" ];
        before = [ "initrd-root-fs.target" ];
        unitConfig.DefaultDependencies = false;
        script = ''
          mkdir -p /var/empty
          echo "systemd-tty-ask-password-agent --watch" > /var/empty/.profile
        '';
        serviceConfig.Type = "oneshot";
      };
    };

    # SSH
    services.openssh = {
      enable = true;
      hostKeys = mkIf cfg.zfs [
        {
          bits = 4096;
          path = "/etc/ssh/ssh_host_rsa_key";
          type = "rsa";
        }
        {
          path = "/etc/ssh/ssh_host_ed25519_key";
          type = "ed25519";
        }
        {
          path = "/var/ssh/ssh_host_ed25519_key";
          type = "ed25519";
        }
      ];
    };

    environment.systemPackages =
      with pkgs;
      mkIf cfg.ansibleTarget [
        python3
      ];
  };
}
