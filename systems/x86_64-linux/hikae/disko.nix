{
  disko.devices = {
    disk = {
      boot = {
        type = "disk";
        device = "/dev/vda";
        content = {
          type = "gpt";
          partitions = {
            ESP = {
              size = "512M";
              type = "EF00";
              content = {
                type = "filesystem";
                format = "vfat";
                mountpoint = "/boot";
              };
            };
            root = {
              size = "100%";
              content = {
                type = "filesystem";
                format = "ext4";
                mountpoint = "/";
              };
            };
          };
        };
      };
      backup = {
        type = "disk";
        device = "/dev/vdb";
        content = {
          type = "gpt";
          partitions = {
            zfs = {
              size = "100%";
              content = {
                type = "zfs";
                pool = "backuppool";
              };
            };
          };
        };
      };
    };
    zpool = {
      backuppool = {
        type = "zpool";
        mode = "";
        options = {
          ashift = "12";
        };
        rootFsOptions = {
          compression = "zstd";
          mountpoint = "none";
        };
      };
    };
  };
}
