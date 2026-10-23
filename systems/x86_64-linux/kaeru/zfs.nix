{ config, ... }:
{
  systemd.services.zfs-delegate-syncoid = {
    wantedBy = [ "multi-user.target" ];
    after = [ "zfs.target" ];
    serviceConfig.Type = "oneshot";
    script = "${config.boot.zfs.package}/bin/zfs allow -u syncoid send,hold,bookmark,snapshot,mount tank";
  };
  users.groups.syncoid = { };
  services.sanoid = {
    enable = true;

    templates = {
      frequent = {
        frequently = 4;
        hourly = 24;
        daily = 7;
        weekly = 2;
        monthly = 1;
        autosnap = true;
        autoprune = true;
      };

      standard = {
        hourly = 12;
        daily = 14;
        weekly = 4;
        monthly = 3;
        autosnap = true;
        autoprune = true;
      };

      archive = {
        daily = 7;
        weekly = 4;
        monthly = 6;
        autosnap = true;
        autoprune = true;
      };

      system = {
        hourly = 0;
        daily = 7;
        weekly = 4;
        monthly = 1;
        autosnap = true;
        autoprune = true;
      };
    };
    datasets = {
      "tank/datadir" = {
        useTemplate = [ "system" ];
        recursive = false;
      };
      "tank/datadir/postgresql" = {
        useTemplate = [ "frequent" ];
        recursive = false;
      };

      "tank/datadir/libvirt" = {
        useTemplate = [ "standard" ];
        recursive = false;
      };

      "tank/datadir/libvirt/benno_backup/data".autosnap = false;

      "tank/data" = {
        useTemplate = [ "standard" ];
        recursive = false;
      };

      "tank/datadir/forgejo" = {
        useTemplate = [ "system" ];
        recursive = false;
      };

      "tank/datadir/forgejo/repositories" = {
        useTemplate = [ "frequent" ];
        recursive = false;
      };

      "tank/datadir/forgejo/data" = {
        useTemplate = [ "frequent" ];
        recursive = false;
      };

      "tank/datadir/forgejo/data/lfs" = {
        useTemplate = [ "standard" ];
        recursive = false;
      };

      "tank/datadir/immich" = {
        useTemplate = [ "standard" ];
        recursive = false;
      };

      "tank/datadir/nextcloud" = {
        useTemplate = [ "standard" ];
        recursive = false;
      };

      "tank/data/paperless" = {
        useTemplate = [ "archive" ];
        recursive = false;
      };

      "tank/media" = {
        useTemplate = [ "archive" ];
        recursive = false;
      };

      "tank/photos" = {
        useTemplate = [ "archive" ];
        recursive = false;
      };

      "zroot/root" = {
        useTemplate = [ "system" ];
        recursive = false;
      };

      "zroot/podman" = {
        useTemplate = [ "standard" ];
        recursive = false;
      };
    };
  };
}
