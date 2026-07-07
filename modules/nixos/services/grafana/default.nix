{
  config,
  lib,
  pkgs,
  ...
}:

with lib;
with lib.types;
let
  cfg = config.holynix.services.grafana;
  cfgC = config.holynix.services.cloudflared;
  cfgS = config.holynix.services;
  cpe = config.services.prometheus.exporters;
in
{

  options.holynix.services.grafana = {
    enable = mkEnableOption "Enable Grafana";
    smtp = {
      enable = mkOption {
        type = bool;
        default = true;
        description = "Enable smtp";
      };
      host = mkOption {
        type = str;
        default = "";
        description = "host of the oAuth provider";
      };
      password = mkOption {
        type = path;
        default = config.sops.secrets."services/grafana/smtp_password".path;
        description = "Password for the smtp server";
      };
    };
    oauth = {
      enable = mkOption {
        type = bool;
        default = true;
        description = "Enable oauth provider";
      };
      client_id = mkOption {
        type = path;
        default = config.sops.secrets."services/grafana/oauth_client_id".path;
        description = "Path to the file containing the client_id";
      };
      client_secret = mkOption {
        type = path;
        default = config.sops.secrets."services/grafana/oauth_client_secret".path;
        description = "Path to the file containing the client_secret";
      };
      scopes = mkOption {
        type = str;
        default = "openid profile email";
        description = "Scope of the oauth request";
      };
      auth_url = mkOption {
        type = str;
        default = "";
        description = "Auth Url of the oauth provider";
      };
      token_url = mkOption {
        type = str;
        default = "";
        description = "Token Url of the oauth provider";
      };
      api_url = mkOption {
        type = str;
        default = "";
        description = "API Url of the oauth provider";
      };
      role_attribute_path = mkOption {
        type = str;
        default = "contains(groups[*], 'Grafana') && 'Viewer'";
        description = "Role attribute path of the oauth provider";
      };
      signout_redirect_url = mkOption {
        type = str;
        default = "";
        description = "Signout redirect Url of the oauth provider";
      };
      name = mkOption {
        type = str;
        default = "Authentik";
        description = "Name of the OAuth provider";
      };
    };
  };

  config = mkIf cfg.enable {
    sops.secrets = {
      "services/grafana/smtp_password" = {
        restartUnits = [ "grafana.service" ];
        owner = "grafana";
        group = "grafana";
      };
      "services/grafana/oauth_client_id" = {
        restartUnits = [ "grafana.service" ];
        owner = "grafana";
        group = "grafana";
      };
      "services/grafana/oauth_client_secret" = {
        restartUnits = [ "grafana.service" ];
        owner = "grafana";
        group = "grafana";
      };
      "services/grafana/admin_pass" = {
        restartUnits = [ "grafana.service" ];
        owner = "grafana";
        group = "grafana";
      };
      "services/grafana/secret_key" = {
        restartUnits = [ "grafana.service" ];
        owner = "grafana";
        group = "grafana";
      };
      "services/grafana/contactPoints" = {
        restartUnits = [ "grafana.service" ];
        owner = "grafana";
        group = "grafana";
      };
    };
    services = {
      cloudflared.tunnels."${cfgC.tunnelId}".ingress."grafana.${cfgS.publicDomain}" =
        mkIf cfgC.enable "https://grafana.${cfgS.privateDomain}";
      grafana = {
        enable = true;
        declarativePlugins = with pkgs.grafanaPlugins; [
          grafana-piechart-panel
          grafana-clock-panel
        ];
        settings = {
          database = {
            type = "postgres";
            host = "/run/postgresql";
            name = "grafana";
            user = "grafana";
          };
          server = {
            root_url = "https://grafana.${cfgS.publicDomain}";
            domain = "grafana.${cfgS.publicDomain}";
            http_port = 3432;
          };
          security = {
            secret_key = "$__file{${config.sops.secrets."services/grafana/secret_key".path}}";
            admin_user = "holyadmin";
            admin_password = "$__file{${config.sops.secrets."services/grafana/admin_pass".path}}";
            csrf_trusted_origins = [
              "grafana.${cfgS.publicDomain}"
              "grafana.${cfgS.privateDomain}"
            ];
            cookie_secure = true;
          };
          smtp = mkIf cfg.smtp.enable {
            enable = true;
            from_address = "grafana@${cfgS.publicDomain}";
            from_name = "Grafana";
            inherit (cfg.smtp) host;
            password = "$__file{${cfg.smtp.password}}";
          };
          "auth.generic_oauth" = mkIf cfg.oauth.enable {
            enabled = true;
            name = cfg.oauth.name;
            client_id = "$__file{${cfg.oauth.client_id}}";
            client_secret = "$__file{${cfg.oauth.client_secret}}";
            scopes = cfg.oauth.scopes;
            auth_url = cfg.oauth.auth_url;
            token_url = cfg.oauth.token_url;
            api_url = cfg.oauth.api_url;
            role_attribute_path = cfg.oauth.role_attribute_path;
            signout_redirect_url = cfg.oauth.signout_redirect_url;
          };
        };
        provision = {
          alerting = {
            contactPoints.path = config.sops.secrets."services/grafana/contactPoints".path;
            templates.path = ./alerting/templates.yaml;
          };
          dashboards.settings.providers = [
            {
              name = "default";
              disableDeletion = false;
              options = {
                path = "/etc/grafana/dashboards";
                foldersFromFilesStructure = true;
              };
            }
          ];
          datasources.settings.datasources = mkIf config.services.prometheus.enable [
            {
              name = "Prometheus";
              type = "prometheus";
              url = "http://127.0.0.1:${toString config.services.prometheus.port}";
              isDefault = true;
              editable = false;
            }
          ];
        };
      };
      caddy = {
        enable = true;
        virtualHosts."grafana.${cfgS.publicDomain}" = {
          serverAliases = [ "grafana.${cfgS.privateDomain}" ];
          extraConfig = ''
            reverse_proxy http://localhost:${toString config.services.grafana.settings.server.http_port}
          '';
        };
      };
      postgresql = {
        enable = true;
        ensureDatabases = [ "grafana" ];
        ensureUsers = [
          {
            name = "grafana";
            ensureDBOwnership = true;
          }
        ];
      };
      postgresqlBackup = {
        enable = true;
        databases = [
          "grafana"
        ];
      };
    };
    environment.etc = {
      "grafana/dashboards/node.json".source = mkIf cpe.node.enable ./dashboards/node.json;
      "grafana/dashboards/postgesql.json".source = mkIf cpe.postgres.enable ./dashboards/postgresql.json;
      "grafana/dashboards/zfs.json".source = mkIf cpe.zfs.enable ./dashboards/zfs.json;
      "grafana/dashboards/smartctl.json".source = mkIf cpe.smartctl.enable ./dashboards/smartctl.json;
      "grafana/dashboards/blackbox.json".source = mkIf cpe.blackbox.enable ./dashboards/blackbox.json;
      "grafana/dashboards/libvirt.json".source = mkIf cpe.libvirt.enable ./dashboards/libvirt.json;
      "grafana/dashboards/nut.json".source = mkIf cpe.nut.enable ./dashboards/nut.json;
      "grafana/dashboards/systemd.json".source = mkIf cpe.systemd.enable ./dashboards/systemd.json;
    };
  };
}
