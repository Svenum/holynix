{
  config,
  lib,
  ...
}:

with lib;
with lib.types;
let
  cfg = config.holynix.services.nextcloud;
  inherit (config.sops) secrets;
in
{

  options.holynix.services.nextcloud = {
    enable = mkOption {
      type = bool;
      default = false;
      description = "Enable nextcloud";
    };
    datadir = mkOption {
      type = str;
      default = "/mnt/storage/nextcloud";
      description = "Path of the User Files";
    };
  };
  config = mkIf cfg.enable {
    holynix.services.enable = true;
    sops.secrets."services/nextcloud/adminpass" = {
      restartUnits = [ "phpfpm-nextcloud.service" ];
    };
    services = {
      nextcloud = {
        enable = true;
        inherit (cfg) datadir;
        hostName = "nextcloud.${config.holynix.services.globalSettings.domain}";
        config = {
          adminuser = config.holynix.services.globalSettings.adminName;
          adminpassFile = secrets."services/nextcloud/adminpass".path;
          dbtype = "sqlite";
        };
        settings = {
          trusted_domains = [ "nextcloud.holypenguin.net" ];
          trusted_proxies = [ "127.0.0.1" ];
          overwriteprotocol = "https";
        };
        extraApps = {
          inherit (config.services.nextcloud.package.packages.apps)
            end_to_end_encryption
            cookbook
            calendar
            contacts
            notes
            previewgenerator
            richdocuments
            ;
        };
        extraAppsEnable = true;
        maxUploadSize = "10G";
      };
      caddy = {
        virtualHosts.${config.services.nextcloud.hostName} = {
          serverAliases = config.services.nextcloud.settings.trusted_domains;
          extraConfig = ''
              reverse_proxy localhost:8080
              request_body {
              max_size 10GB
            }

          '';
        };
      };
    };

    services.nginx.virtualHosts."${config.services.nextcloud.hostName}".listen = [
      {
        addr = "127.0.0.1";
        port = 8080;
      }
    ];

  };
}
