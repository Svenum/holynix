{ lib, config, ... }:

with lib;
with lib.types;

let
  cfg = config.holynix.services;
in
{
  options.holynix.services = {
    publicDomain = mkOption {
      type = nullOr str;
      default = null;
      description = "The public domain for the servcies";
    };

    privateDomain = mkOption {
      type = nullOr str;
      default =
        if (cfg.publicDomain == null) then null else "${config.networking.hostName}.${cfg.publicDomain}";
      description = "The private domain for the services";
    };
    listeningIp = mkOption {
      type = nullOr str;
      default = null;
      description = "Set the default ip address for exported services";
    };
    sopsDir = mkOption {
      type = path;
      default = ../../../secrets/${config.networking.hostName}/services;
      description = "Directory in which the sopssecrets are stored";
    };
  };

  config = {
    # dummy nginx user
    users = {
      users.nginx = {
        isSystemUser = true;
        group = "nginx";
      };
      groups.nginx = { };
    };
    services = {
      nginx.enable = mkForce false;
      postgresqlBackup = {
        enable = config.services.postgresql.enable;
        compression = "zstd";
        startAt = "*-*-* 12:00:00";
        location = "/var/lib/backup/postgresql";
      };
    };
  };
}
