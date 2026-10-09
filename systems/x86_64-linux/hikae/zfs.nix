{ config, ... }:

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
      datasets."/srv/backuppool/kaeru" = {
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
      ];
      commands."tank/data" = {
        target = "/srv/backuppool/kaeru";
        source = "syncoid@100.86.235.4:tank";
        recursive = true;
        extraArgs = [
          "--exclude-datasets=^tank/media"
          "--exclude-datasets=^tank/datadir/libvirt"
        ];
        sendOptions = "w"; # raw send, keeps encryption, no key on target
        recvOptions = "u"; # don't mount received datasets
      };
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
