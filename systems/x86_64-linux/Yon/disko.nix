{
  disko.devices = {
    disk = {
      main = {
        type = "disk";
        device = "/dev/nvme0n1"; # adjust to your device
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
                mountOptions = [
                  "fmask=0022"
                  "dmask=0022"
                ];
              };
            };
            root = {
              size = "100%";
              content = {
                type = "btrfs";
                extraArgs = [
                  "-L"
                  "nixos"
                  "-f"
                ];
                subvolumes = {
                  "@" = {
                    mountpoint = "/";
                    mountOptions = [
                      "subvol=@"
                      "compress=zstd:3"
                      "noatime"
                      "space_cache=v2"
                      "ssd"
                      "discard=async"
                    ];
                  };
                  "@home" = {
                    mountpoint = "/home";
                    mountOptions = [
                      "subvol=@home"
                      "compress=zstd:3"
                      "noatime"
                      "space_cache=v2"
                      "ssd"
                      "discard=async"
                    ];
                  };
                  "@nix" = {
                    mountpoint = "/nix";
                    mountOptions = [
                      "subvol=@nix"
                      "compress=zstd:3"
                      "noatime"
                      "space_cache=v2"
                      "ssd"
                      "discard=async"
                    ];
                  };
                  "@log" = {
                    mountpoint = "/var/log";
                    mountOptions = [
                      "subvol=@log"
                      "compress=zstd:3"
                      "noatime"
                      "space_cache=v2"
                      "ssd"
                      "discard=async"
                    ];
                  };
                  "@snapshots" = {
                    mountpoint = "/.snapshots";
                    mountOptions = [
                      "subvol=@snapshots"
                      "compress=zstd:3"
                      "noatime"
                      "space_cache=v2"
                      "ssd"
                      "discard=async"
                    ];
                  };
                  "@swap" = {
                    mountpoint = "/swap";
                    mountOptions = [
                      "subvol=@swap"
                      "noatime"
                    ];
                    swap = {
                      swapfile.size = "8G"; # adjust to your RAM
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
  };
}
