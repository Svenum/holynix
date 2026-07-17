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
  cfgC = config.holynix.services.cloudflared;
  cfgS = config.holynix.services;
in
{
  options.holynix.services.nextcloud = {
    enable = mkEnableOption "Enable Nextcloud service";
    enableRichdocuments = mkOption {
      type = bool;
      default = config.services.collabora-online.enable;
      description = "Enable richdocuments integration";
    };
    ldap = {
      enable = mkOption {
        type = bool;
        default = false;
        description = "Enable ldap for nextcloud";
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

    users = {
      users.nextcloud.extraGroups = [ "video" ];
      groups.nextcloud.members = [
        "nextcloud"
        config.services.caddy.user
      ];
    };

    sops.secrets = {
      "services/nextcloud/admin_pass" = { };
      "services/nextcloud/ldap_pass".restartUnits = mkIf cfg.ldap.enable [
        "nextcloud-setup-ldap.service"
      ];
    };

    systemd.services = {
      phpfpm-nextcloud.serviceConfig = {
        DeviceAllow = "/dev/dri/renderD128 rw";
        PrivateDevices = mkForce false;
      };

      nextcloud-setup-richdocuments = mkIf cfg.enableRichdocuments {
        path = [
          config.services.nextcloud.occ
        ];
        script = ''
          nextcloud-occ app:enable richdocuments
          nextcloud-occ config:app:set richdocuments wopi_url --value https://collabora.${cfgS.publicDomain}
          nextcloud-occ richdocuments:activate-config
        '';
        after = [ "nextcloud-setup.service" ];
        wantedBy = [ "multi-user.target" ];
      };

      nextcloud-setup-files_external = {
        path = [
          config.services.nextcloud.occ
        ];
        script = ''
          nextcloud-occ app:enable files_external
          nextcloud-occ config:app:set files_external allow_user_mounting --value=1
          nextcloud-occ config:app:set files_external user_mounting_backends --value="dav,owncloud,sftp,\OC\Files\Storage\SFTP_Key"
        '';
        after = [ "nextcloud-setup.service" ];
        wantedBy = [ "multi-user.target" ];
      };
      nextcloud-setup-ldap = mkIf cfg.ldap.enable {
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
          nextcloud-occ ldap:set-config s01 ldapAttributesForUserSearch ${cfg.ldap.userAttribute}
          nextcloud-occ ldap:set-config s01 ldapBase ${cfg.ldap.dn}
          nextcloud-occ ldap:set-config s01 ldapBaseGroups ${cfg.ldap.dn}
          nextcloud-occ ldap:set-config s01 ldapBaseUsers ${cfg.ldap.dn}
          nextcloud-occ ldap:set-config s01 ldapConfigurationActive 1
          nextcloud-occ ldap:set-config s01 ldapExperiencedAdmin mail 
          nextcloud-occ ldap:set-config s01 ldapExpertUUIDGroupAttr ${cfg.ldap.userAttribute}
          nextcloud-occ ldap:set-config s01 ldapExpertUUIDUserAttr ${cfg.ldap.userAttribute}
          nextcloud-occ ldap:set-config s01 ldapExpertUsernameAttr ${cfg.ldap.userAttribute}
          nextcloud-occ ldap:set-config s01 ldapGroupFilterGroups '${cfg.ldap.groupFilter}'
          nextcloud-occ ldap:set-config s01 ldapGroupMemberAssocAttr member
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
          nextcloud-occ ldap:set-config s01 ldapUserFilterMode 1
          nextcloud-occ ldap:set-config s01 ldapUserFilterObjectclass user
          nextcloud-occ ldap:set-config s01 ldapAgentPassword $(cat ${
            config.sops.secrets."services/nextcloud/ldap_pass".path
          })
        '';
        after = [ "nextcloud-setup.service" ];
        wantedBy = [ "multi-user.target" ];
      };
      nextcloud-setup-theming = {
        path = [
          config.services.nextcloud.occ
        ];
        script = ''
          nextcloud-occ theming:config url https://${config.services.nextcloud.hostName}
          nextcloud-occ theming:config primary_color '#94E2D5'
          nextcloud-occ theming:config background_color '#313244'
          nextcloud-occ theming:config background backgroundColor
          nextcloud-occ config:app:set theming_customcss customcss --value '${readFile ./custom.css}'
        '';
        after = [ "nextcloud-setup.service" ];
        wantedBy = [ "multi-user.target" ];
      };
      nextcloud-setup-other = {
        path = [
          config.services.nextcloud.occ
        ];
        script = ''
          nextcloud-occ app:disable logreader
          nextcloud-occ app:disable app_api
          nextcloud-occ config:app:set core emailTestSuccessful --value=1
        '';
        after = [ "nextcloud-setup.service" ];
        wantedBy = [ "multi-user.target" ];
      };
    };

    services = {
      cloudflared.tunnels."${cfgC.tunnelId}".ingress."nextcloud.${cfgS.publicDomain}" =
        mkIf cfgC.enable "https://nextcloud.${cfgS.privateDomain}";
      nextcloud = {
        enable = true;
        hostName = "nextcloud.${cfgS.publicDomain}";
        maxUploadSize = "100G";
        phpOptions."opcache.interned_strings_buffer" = "24";
        database.createLocally = true;
        imaginary.enable = true;
        settings = {
          trusted_domains = [
            "nextcloud.${cfgS.publicDomain}"
            "nextcloud.${cfgS.privateDomain}"
          ];
          trusted_proxies = [ "127.0.0.1" ];
          maintenance_window_start = 1;
          "integrity.check.disabled" = true;
          default_phone_region = "DE";
          serverid = 1;
          log_type = "systemd";
        };
        config = {
          dbtype = "pgsql";
          # Should contain:
          # AMDINPASSWORD
          adminpassFile = config.sops.secrets."services/nextcloud/admin_pass".path;
          adminuser = "holyadmin";
        };
        package = pkgs.nextcloud33;
        extraApps = {
          inherit (config.services.nextcloud.package.packages.apps)
            calendar
            contacts
            cookbook
            cospend
            end_to_end_encryption
            notes
            theming_customcss
            groupfolders
            richdocuments
            ;
        };
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

            @davClnt {
              header_regexp User-Agent ^DavClnt
              path /
            }
            redir @davClnt /remote.php/webdev{uri} 302

            @sensitive {
              path /build     /build/*
              path /tests     /tests/*
              path /config    /config/*
              path /lib       /lib/*
              path /3rdparty  /3rdparty/*
              path /templates /templates/*
              path /data      /data/*
              path /.*
              path /autotest*
              path /occ*
              path /issue*
              path /indie*
              path /db_*
              path /console*
            }
            respond @sensitive 404

            root * ${config.services.nextcloud.finalPackage}

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
