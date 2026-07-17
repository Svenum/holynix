{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
with lib.types;
let
  cfg = config.holynix.services.ups;
in
{
  options.holynix.services.ups = {
    enable = mkEnableOption "Enable UPS service";
  };

  config = mkIf cfg.enable {
    sops.secrets = {
      "services/ups/monmaster_passwd".restartUnits = [ "upsd" ];
      "services/ups/exporter_passwd" = {
        restartUnits = [ "upsd" ];
        owner = config.services.prometheus.exporters.nut.user;
        group = config.services.prometheus.exporters.nut.group;
        mode = "0440";
      };
    };
    power.ups = {
      enable = true;
      mode = "standalone";

      ups.eaton = {
        driver = "usbhid-ups";
        port = "auto";
        description = "Eaton UPS";
      };

      upsmon = {
        enable = true;
        monitor.eaton = {
          system = "eaton@localhost";
          powerValue = 1;
          user = "monmaster";
          type = "master";
        };
        settings.SHUTDOWNCMD = "${pkgs.systemd}/bin/systemctl poweroff";
      };

      upsd = {
        enable = true;
        listen = [
          {
            address = "127.0.0.1";
            port = 3493;
          }
        ];
      };

      users.monmaster = {
        passwordFile = config.sops.secrets."services/ups/monmaster_passwd".path;
        upsmon = "primary";
      };

      # add a separate read-only user for the exporter
      users.exporter = {
        passwordFile = config.sops.secrets."services/ups/exporter_passwd".path;
        upsmon = "secondary";
        actions = [ ];
        instcmds = [ ];
      };
    };
  };
}
