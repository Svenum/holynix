{ lib, config, ... }:

with lib;
with lib.types;
let
  cfg = config.holynix.services.nextcloud;
  cfgS = config.holynix.services;
in
{
  options.holynix.services.nextcloud.enable = mkEnableOption "Enable Nextcloud service";

  config = mkIf cfg.enable {

    users.groups.nextcloud.members = [
      "nextcloud"
      config.services.caddy.user
    ];

    services = {
      nextcloud = {
        enable = true;
        hostName = "nextcloud.${cfgS.publicDomain}";
        maxUploadSize = "100G";
        database.createLocally = true;
        imaginary.enable = true;
        config = {
          dbtype = "pgsql";
          # Shoulc contain:
          # AMDINPASSWORD
          adminpassFile = config.sops.secrets."services/nextcloud/admin_pass".path;
          adminuser = "holyadmin";
        };
        package = pkgs.nextcloud33;
      };

      phpfpm.pools.nextcloud.settings = {
        "listen.owner" = config.services.caddy.user;
        "listen.group" = config.services.caddy.group;
      };

      caddy = {
        enable = true;
        virtualHosts."nextcloud.${cfgS.publicDomain}" = {
          serverAliases = [ "nextcloud.${cfgS.privateDomain}" ];
          extraConfig = ''
            header {
              Strict-Transport-Security max-age=31536000;
            }

            redir /.well-known/carddav   /remote.php/dav 301
            redir /.well-known/caldav    /remote.php/dav 301
            redir /.well-known/webfinger /index.php/.well-known/webfinger
            redir /.well-known/nodeinfo  /index.php/.well-known/nodeinfo

            @store_apps path_regexp ^/store-apps
            root @store_apps ${config.services.nextcloud.home}

            @nix_apps path_regexp ^/nix-apps
            root @nix_apps ${config.services.nextcloud.home}

            root * ${config.services.nextcloud.package}


            @davClnt {
              header_regexp User-Agent ^DavClnt
              path /
            }

            redir @davClnt /remote.php/webdev{uri} 302


            @sensitive {
              # ^/(?:build|tests|config|lib|3rdparty|templates|data)(?:$|/)
              path /build     /build/*
              path /tests     /tests/*
              path /config    /config/*
              path /lib       /lib/*
              path /3rdparty  /3rdparty/*
              path /templates /templates/*
              path /data      /data/*

              # ^/(?:\.|autotest|occ|issue|indie|db_|console)
              path /.*
              path /autotest*
              path /occ*
              path /issue*
              path /indie*
              path /db_*
              path /console*
            }
            respond @sensitive 404

            php_fastcgi unix/${config.services.phpfpm.pools.nextcloud.socket} {
              env front_controller_active true
            }
            file_server
          '';
        };
      };
    };
  };
}
