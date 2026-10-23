{
  config,
  lib,
  ...
}:

with lib;
with lib.types;
let
  cfg = config.holynix.services.forgejo;
  cfgC = config.holynix.services.cloudflared;
  cfgS = config.holynix.services;
in
{
  options.holynix.services.forgejo = {
    enable = mkEnableOption "Enable forgejo.";
    mail = {
      enable = mkOption {
        type = bool;
        default = false;
        description = "Enable mails.";
      };
      address = mkOption {
        type = str;
        default = "";
        description = "Mail address to use.";
      };
      server = mkOption {
        type = str;
        default = "";
        description = "SMTP server address.";
      };
    };
    oauth = {
      enable = mkOption {
        type = bool;
        default = cfgS.authentik.enable;
        description = "Enable OAuth connection.";
      };
    };
  };

  config = mkIf cfg.enable {

    catppuccin.forgejo = {
      enable = true;
      accent = "teal";
      flavor = "mocha";
    };

    sops.secrets = {
      "services/forgejo/mailer_pw" = mkIf cfg.mail.enable { };
      "services/forgejo/runner_token" = { };
      "services/forgejo/admin_pw" = {
        owner = config.services.forgejo.user;
        group = config.services.forgejo.group;
      };
    };

    services = {
      forgejo = {
        enable = true;
        database.type = "postgres";
        lfs.enable = true;
        settings = {
          server = {
            DOMAIN = cfgS.publicDomain;
            ROOT_URL = "https://${cfgS.publicDomain}/";
            HTTP_PORT = 3012;
            SSH_PORT = head config.services.openssh.ports;
          };
          service = {
            ALLOW_ONLY_EXTERNAL_REGISTRATION = true;
            DISABLE_REGISTRATION = false;
            SHOW_REGISTRATION_BUTTON = false;
          };
          actions = {
            ENABLED = true;
            DEFAULT_ACTIONS_URL = "github";
          };
          mailer = mkIf cfg.mail.enable {
            ENABLED = true;
            SMTP_ADDR = "mail.example.com";
            FROM = cfg.mail.address;
            USER = cfg.mail.address;
            PORT = 465;
          };
          oauth2_client = mkIf cfg.oauth.enable {
            REGISTER_EMAIL_CONFIRM = "disable";
            OPENID_CONNECT_SCOPES = "email profile";
            ENABLE_AUTO_REGISTRATION = true;
            USERNAME = "preferred_username";
            UPDATE_AVATAR = true;
            ACCOUNT_LINKING = "login";
          };
        };
        secrets = mkIf cfg.mail.enable {
          mailer.PASSWD = config.sops.secrets."services/forgejo/mailer_pw".path;
        };
      };
      forgejo-runner = {
        instances.default = {
          enable = true;
          runtimes.host = true;
          settings.runner.labels = [
            "ubuntu-26.04:docker://node:16-bullseye"
          ];
          secrets.server.connections."forgejo".token_url =
            config.sops.secrets."services/forgejo/runner_token".path;
          settings.server.connections.forgejo = {
            url = "https://localhost:${toString config.services.forgejo.settings.server.HTTP_PORT}";
            uuid = "01a167df-4922-7c5a-98f5-40e1699b93f4";
          };
        };
      };

      caddy = {
        enable = true;
        virtualHosts."forgejo.${cfgS.privateDomain}" = {
          serverAliases = [ "forgejo.${cfgS.publicDomain}" ];
          extraConfig = ''
            request_body {
              max_size 512M
            }
            reverse_proxy http://localhost:${toString config.services.forgejo.settings.server.HTTP_PORT}
          '';
        };
      };

      cloudflared.tunnels."${cfgC.tunnelId}".ingress."forgejo.${cfgS.publicDomain}" =
        mkIf cfgC.enable "https://forgejo.${cfgS.privateDomain}";
    };

    systemd.services.forgejo.preStart =
      let
        adminCmd = "${lib.getExe config.services.forgejo.package} admin user";
        pwd = config.sops.secrets."services/forgejo/admin_pw".path;
        user = "holyladmin";
      in
      ''
        ${adminCmd} create --admin --email "root@localhost" --username ${user} --password "$(tr -d '\n' < ${pwd})" || true
      '';
  };
}
