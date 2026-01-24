{ lib, config, ... }:

with lib;
with lib.types;
{
  options.holynix.services.globalSettings = {
    domain = mkOption {
      type = str;
      default = "${config.networking.hostName}.holypenguin.net";
      description = "Domain under which the services are deployed";
    };
    adminName = mkOption {
      type = str;
      default = "holyadmin";
      description = "Name of the admin Accounts";
    };
    sopsDir = mkOption {
      type = path;
      default = ../../../secrets/${config.networking.hostName}/services;
      description = "Directory in which the sopssecrets are stored";
    };
  };
}
