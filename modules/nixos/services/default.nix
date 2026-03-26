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
    sopsDir = mkOption {
      type = path;
      default = ../../../secrets/${config.networking.hostName}/services;
      description = "Directory in which the sopssecrets are stored";
    };
  };
}
