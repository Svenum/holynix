{
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
      "tank/datadir/postgresql" = {
        useTemplate = [ "frequent" ];
        recursive = false;
      };

      "tank/datadir/libvirt" = {
        useTemplate = [ "standard" ];
        recursive = false;
      };

      "tank/smb" = {
        useTemplate = [ "standard" ];
        recursive = false;
      };

      "tank/media" = {
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
