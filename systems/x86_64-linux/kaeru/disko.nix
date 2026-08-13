let
  os = "/dev/sdc";
  data1 = "/dev/sda";
  data2 = "/dev/sdb";
  data3 = "/dev/sdd";
  data4 = "/dev/sde";
  special1 = "/dev/nvme0n1";
  special2 = "/dev/nvme1n1";
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
          acltype = "posixacl";
          xattr = "sa";
          mountpoint = "none";
        };
        options = {
          ashift = "12";
        };
        datasets = {
          "podman" = {
            type = "zfs_fs";
            mountpoint = "/var/lib/containers/storage/volumes";
            options = {
              compression = "zstd";
            };
          };
          "root" = {
            type = "zfs_fs";
            mountpoint = "/";
            options = {
              compression = "zstd";
              encryption = "aes-256-gcm";
              keyformat = "passphrase";
              keylocation = "prompt";
            };
          };
          "nix" = {
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
        };
        rootFsOptions = {
          compression = "zstd";
          mountpoint = "none";
          special_small_blocks = "64K";
          encryption = "aes-256-gcm";
          keyformat = "passphrase";
          keylocation = "prompt";
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
            };
          };
          "datadir/postgresql" = {
            type = "zfs_fs";
            mountpoint = "/var/lib/postgresql";
            options = {
              compression = "zstd";
              recordsize = "8K";
              logbias = "latency";
            };
          };
          "datadir/libvirt" = {
            type = "zfs_fs";
            mountpoint = "/var/lib/libvirt/images";
            options = {
              compression = "zstd";
              recordsize = "64K";
            };
          };
          "datadir/immich" = {
            type = "zfs_fs";
            mountpoint = "/var/lib/immich";
            options = {
              compression = "zstd";
              atime = "off";
              xattr = "sa";
              acltype = "posixacl";
              recordsize = "1M";
            };
          };
          "datadir/paperless" = {
            type = "zfs_fs";
            mountpoint = "/srv/data/paperless";
            options = {
              recordsize = "128K";
              compression = "zstd";
            };
          };
          "media" = {
            type = "zfs_fs";
            mountpoint = "/srv/media";
            options = {
              compression = "zstd";
              atime = "off";
              recordsize = "1M";
              special_small_blocks = "0";
            };
          };
          "photos" = {
            type = "zfs_fs";
            mountpoint = "/srv/photos";
            options = {
              compression = "zstd";
              recordsize = "128K";
              special_small_blocks = "32K";
              atime = "off";
            };
          };
          "data" = {
            type = "zfs_fs";
            mountpoint = "/srv/data";
            options = {
              compression = "zstd";
            };
          };
        };
      };
    };
  };
}
