{ lib, config, ... }:

with lib;
with lib.types;
let
  cfg = config.holynix.services;
in
{
  options.holynix.services = {
    enable = mkOption {
      type = bool;
      default = false;
      description = "Enable caddy and needed stuff for services";
    };
    globalSettings = {
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
  };

  config = mkIf cfg.enable {
    holynix.services.caddy.enable = true;
  };
}
