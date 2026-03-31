{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
with lib.types;
let
  cfg = config.holynix.services.nextcloud;
  cfgS = config.holynix.services;
in
{
  options.holynix.services.nextcloud = {
    enable = mkEnableOption "Enable Nextcloud service";
    ldap = {
      enable = mkOption {
        type = bool;
        default = false;
        description = "Enabel ldap for nextcloud";
      };
      bindDN = mkOption {
        type = nullOr str;
        default = null;
        description = "BindDN for nextcloud";
      };
      userAttribute = mkOption {
        type = str;
        default = "cn";
        description = "Unique ldap attribute for the name of the users";
      };
      emailAttribute = mkOption {
        type = str;
        default = "mail";
        description = "Ldap attribute for the mail of the users";
      };
      dn = mkOption {
        type = nullOr str;
        default = null;
        description = "Base dn of ldap";
      };
      groupFilter = mkOption {
        type = nullOr str;
        default = null;
        description = "Filter for the groups";
      };
      loginFilter = mkOption {
        type = nullOr str;
        default = null;
        description = "Filter for the login";
      };
      userFilter = mkOption {
        type = nullOr str;
        default = null;
        description = "Filter for the users";
      };
      host = mkOption {
        type = nullOr str;
        default = null;
        description = "Host of the ldap";
        example = "ldaps://ldap.example.com";
      };
      port = mkOption {
        type = int;
        default = 636;
        description = "Port of the ldap";
      };
    };
  };

  config = mkIf cfg.enable {

    users.groups.nextcloud.members = [
      "nextcloud"
      config.services.caddy.user
    ];

    sops.secrets = {
      "services/nextcloud/admin_pass" = { };
      "services/nextcloud/ldap_pass".restartUnits = mkIf cfg.ldap.enable [
        "nextcloud-setup-ldap.service"
      ];
    };

    systemd.services.nextcloud-setup-ldap = mkIf cfg.ldap.enable {
      path = [
        config.services.nextcloud.occ
      ];
      script = ''
        nextcloud-occ app:enable user_ldap
        if [[ -z "$(nextcloud-occ ldap:show-config)" ]]; then
          nextcloud-occ ldap:create-empty-config
        fi
        nextcloud-occ ldap:set-config s01 hasMemberOfFilterSupport 1
        nextcloud-occ ldap:set-config s01 ldapAgentName ${cfg.ldap.bindDN}
        nextcloud-occ ldap:set-config s01 ldapAgentPassword $(cat ${
          config.sops.secrets."services/nextcloud/ldap_pass".path
        })
        nextcloud-occ ldap:set-config s01 ldapAttributeForUserSearch ${cfg.ldap.userAttribute}
        nextcloud-occ ldap:set-config s01 ldapBase ${cfg.ldap.dn}
        nextcloud-occ ldap:set-config s01 ldapBaseGroups ${cfg.ldap.dn}
        nextcloud-occ ldap:set-config s01 ldapBaseUsers ${cfg.ldap.dn}
        nextcloud-occ ldap:set-config s01 ldapConfigurationActive 1
        nextcloud-occ ldap:set-config s01 ldapExpertUUIDGroupAttr ${cfg.ldap.userAttribute}
        nextcloud-occ ldap:set-config s01 ldapExpertUUIDUserAttr ${cfg.ldap.userAttribute}
        nextcloud-occ ldap:set-config s01 ldapExpertUsernameAttr ${cfg.ldap.userAttribute}
        nextcloud-occ ldap:set-config s01 ldapGroupFilter '${cfg.ldap.groupFilter}'
        nextcloud-occ ldap:set-config s01 ldapGroupFilterObjectclass group
        nextcloud-occ ldap:set-config s01 ldapGidNumber gidnumber
        nextcloud-occ ldap:set-config s01 ldapGroupDisplayName cn
        nextcloud-occ ldap:set-config s01 ldapHost ${cfg.ldap.host}
        nextcloud-occ ldap:set-config s01 ldapPort ${toString cfg.ldap.port}
        nextcloud-occ ldap:set-config s01 ldapLoginFilter '${cfg.ldap.loginFilter}'
        nextcloud-occ ldap:set-config s01 ldapLoginFilterEmail 1
        nextcloud-occ ldap:set-config s01 ldapLoginFilterMode 1
        nextcloud-occ ldap:set-config s01 ldapLoginFilterUsername 1
        nextcloud-occ ldap:set-config s01 ldapLoginFilterAttributes 'cn;displayName;mail'
        nextcloud-occ ldap:set-config s01 ldapUserFilter '${cfg.ldap.userFilter}'
      '';
      after = [ "nextcloud-setup.service" ];
      wantedBy = [ "multi-user.target" ];
    };

    services = {
      nextcloud = {
        enable = true;
        hostName = "nextcloud.${cfgS.publicDomain}";
        maxUploadSize = "100G";
        database.createLocally = true;
        imaginary.enable = true;
        settings.trusted_domains = [
          "nextcloud.${cfgS.publicDomain}"
          "nextcloud.${cfgS.privateDomain}"
        ];
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

      postgresqlBackup = {
        enable = true;
        databases = [
          "nextcloud"
        ];
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
