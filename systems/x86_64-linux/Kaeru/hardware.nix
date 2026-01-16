_:

let
  ssdOptions = [
    "noatime"
    "nodiratime"
    "discard"
  ];
in
{
  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx";
      fsType = "btrfs";
      options = ssdOptions;
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx";
      fsType = "vfat";
      options = ssdOptions;
    };

    "/mnt/vms" = {
      device = "/dev/disk/by-uuid/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx";
      fsType = "btrfs";
      options = [
        "subvol=vms"
      ]
      ++ ssdOptions;
    };
    "/mnt/container" = {
      device = "/dev/disk/by-uuid/xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxx";
      fsType = "btrfs";
      options = [
        "subvol=container"
      ]
      ++ ssdOptions;
    };

  };
}
