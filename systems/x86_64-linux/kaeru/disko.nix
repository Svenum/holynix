{ config, ... }:

let
  os = "/dev/sd";
  data1 = "/dev/sd";
  data2 = "/dev/sd";
  data3 = "/dev/sd";
  data4 = "/dev/sd";
  special1 = "/dev/nvme";
  special2 = "/dev/nvme";
in
{
  disko.devices = {
    disk = {
      os = {
        type = "disk";
        device = os;
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "2G";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
                mountOptions = [ "umask=0077" ];
              };
            };
            root = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "zroot";
              };
            };
          };
        };
      };
      data1 = {
        type = "disk";
        device = data1;
        content = {
          type = "gpt";
          partitions.zfs = {
            size = "100%";
            content = {
              type = "zfs";
              pool = "tank";
            };
          };
        };
      };
      data2 = {
        type = "disk";
        device = data2;
        content = {
          type = "gpt";
          partitions.zfs = {
            size = "100%";
            content = {
              type = "zfs";
              pool = "tank";
            };
          };
        };
      };
      data3 = {
        type = "disk";
        device = data3;
        content = {
          type = "gpt";
          partitions.zfs = {
            size = "100%";
            content = {
              type = "zfs";
              pool = "tank";
            };
          };
        };
      };
      data4 = {
        type = "disk";
        device = data4;
        content = {
          type = "gpt";
          partitions.zfs = {
            size = "100%";
            content = {
              type = "zfs";
              pool = "tank";
            };
          };
        };
      };
      special1 = {
        type = "disk";
        device = special1;
        content = {
          type = "gpt";
          partitions.zfs = {
            size = "100%";
            content = {
              type = "zfs";
              pool = "tank";
            };
          };
        };
      };
      special2 = {
        type = "disk";
        device = special2;
        content = {
          type = "gpt";
          partitions.zfs = {
            size = "100%";
            content = {
              type = "zfs";
              pool = "tank";
            };
          };
        };
      };
    };
    zpool = {
      zroot = {
        type = "zpool";
        rootFsOptions = {
          compression = "zstd";
          "com.sun:auto-snapshot" = "false";
          acltype = "posixacl";
          xattr = "sa";
          mountpoint = "none";
        };
        options = {
          encryption = "aes-256-gcm";
          keyformat = "passphrase";
          keylocation = "prompt";
          ashift = "12";
        };
        datasets = {
          "podman" = {
            type = "zfs_fs";
            mountpoint = "/var/lib/containers/storage/volumes";
            options = {
              "com.sun:auto-snapshot" = "false";
              compression = "zstd";
            };
          };
          "root" = {
            type = "zfs_fs";
            mountpoint = "/";

          };
          "root/nix" = {
            type = "zfs_fs";
            options.mountpoint = "/nix";
            mountpoint = "/nix";
          };
        };
      };
      tank = {
        type = "zpool";
        options = {
          ashift = "12";
          encryption = "aes-256-gcm";
          keyformat = "passphrase";
          keylocation = "file:///etc/secrets/tank.key";
        };
        rootFsOptions = {
          compression = "zstd";
          "com.sun:auto-snapshot" = "false";
          mountpoint = "none";
          special_small_blocks = "64K";
        };
        mode.topology = {
          type = "topology";
          vdev = [
            {
              mode = "raidz2";
              members = [
                "data1"
                "data2"
                "data3"
                "data4"
              ];
            }
          ];
          special = {
            mode = "mirror";
            members = [
              "special1"
              "special2"
            ];
          };
        };
        datasets = {
          "datadir" = {
            type = "zfs_fs";
            mountpoint = "/var/lib";
            options = {
              compression = "zstd";
              "com.sun:auto-snapshot" = "true";
            };
          };
          "datadir/postgresql" = {
            type = "zfs_fs";
            mountpoint = "/var/lib/postgresql";
            options = {
              compression = "zstd";
              recordsize = "8K";
              logbias = "latency";
              "com.sun:auto-snapshot" = "true";
            };
          };
          "datadir/libvirt" = {
            type = "zfs_fs";
            mountpoint = "/var/lib/libvirt/images";
            options = {
              compression = "zstd";
              recordsize = "64K";
              "com.sun:auto-snapshot" = "true";
            };
          };
          "media" = {
            type = "zfs_fs";
            mountpoint = "/srv/media";
            options = {
              compression = "off";
              atime = "off";
              recordsize = "1M";
              "com.sun:auto-snapshot" = "false";
              special_small_blocks = "0";
            };
          };
          "smb" = {
            type = "zfs_fs";
            mountpoint = "/srv/smb";
            options = {
              compression = "zstd";
              "com.sun:auto-snapshot" = "true";
            };
          };
        };
      };
    };
  };
  sops.secrets."tank-key" = {
    path = "/etc/secrets/tank.key";
    mode = "0400";
  };

  systemd.services."zfs-import-tank" = {
    after = [ "sops-nix.service" ];
    requires = [ "sops-nix.service" ];
  };
}
