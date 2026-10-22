{ config, ... }:

let
  datasets = [
    "tank/data"
    "tank/datadir/immich"
    "tank/datadir/postgresql"
    "tank/datadir/nextcloud"
    "tank/photos"
  ];
  mkCommands =
    datasets:
    builtins.listToAttrs (
      map (d: {
        name = d;
        value = {
          source = d;
          target = "backuppool/kaeru/${d}";
          recursive = false;
          sendOptions = "w";
          recvOptions = "u";
        };
      }) datasets
    );
in
{
  sops.secrets."services/syncoid/sshKey" = {
    owner = "syncoid";
    group = "syncoid";
  };

  services = {
    sanoid = {
      enable = true;
      templates.backup = {
        hourly = 36;
        daily = 30;
        monthly = 12;
        autosnap = false;
        autoprune = true;
      };
      datasets."backuppool/kaeru" = {
        useTemplate = [ "backup" ];
        recursive = true;
      };
    };
    syncoid = {
      enable = true;
      interval = "hourly";
      user = "syncoid";
      sshKey = config.sops.secrets."services/syncoid/sshKey".path;
      commonArgs = [
        "--no-sync-snap"
        "--create-bookmark"
        "--compress=none"
        "--no-privilege-elevation"
      ];
      commands = mkCommands datasets;
      localSourceAllow = [
        "bookmark"
        "hold"
        "send"
        "snapshot"
        "destroy"
        "mount"
      ];
      localTargetAllow = [
        "compression"
        "create"
        "destroy"
        "hold"
        "mount"
        "mountpoint"
        "receive"
        "rollback"
      ];
    };
  };
}
