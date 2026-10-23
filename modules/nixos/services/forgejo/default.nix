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
    runner = {
      enable = mkOption {
        type = bool;
        default = false;
        description = "Enable runner.";
      };
      uuid = mkOption {
        type = str;
        default = "";
        description = "UUID of runner";
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
            DOMAIN = "forgejo.${cfgS.publicDomain}";
            ROOT_URL = "https://forgejo.${cfgS.publicDomain}/";
            HTTP_PORT = 3012;
            SSH_PORT = head config.services.openssh.ports;
          };
          service = {
            ALLOW_ONLY_EXTERNAL_REGISTRATION = true;
            DISABLE_REGISTRATION = false;
            SHOW_REGISTRATION_BUTTON = false;
          };
          actions = mkIf cfg.runner.enable {
            ENABLED = true;
            DEFAULT_ACTIONS_URL = "github";
          };
          migrations = {
            ALLOWED_DOMAINS = "github.com,*.github.com";
            ALLOW_LOCALNETWORKS = true;
          };
          mailer = mkIf cfg.mail.enable {
            ENABLED = true;
            SMTP_ADDR = cfg.mail.server;
            PROTOCOL = "smtps";
            FROM = cfg.mail.address;
            USER = cfg.mail.address;
            PORT = 465;
          };
          oauth2_client = mkIf cfg.oauth.enable {
            REGISTER_EMAIL_CONFIRM = "disable";
            OPENID_CONNECT_SCOPES = "email profile";
            ENABLE_AUTO_REGISTRATION = true;
            UPDATE_AVATAR = true;
            ACCOUNT_LINKING = "login";
          };
        };
        secrets = mkIf cfg.mail.enable {
          mailer.PASSWD = config.sops.secrets."services/forgejo/mailer_pw".path;
        };
      };
      forgejo-runner = mkIf cfg.runner.enable {
        instances.default = {
          enable = true;
          runtimes.host = true;
          settings.runner.labels = [
            "ubuntu-26.04:docker://node:16-bullseye"
            "nix-unstable:docker://nixpkgs/nix"
          ];
          secrets.server.connections."forgejo".token_url =
            config.sops.secrets."services/forgejo/runner_token".path;
          settings.server.connections.forgejo = {
            url = "http://localhost:${toString config.services.forgejo.settings.server.HTTP_PORT}";
            uuid = cfg.runner.uuid;
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
        user = "holyadmin";
      in
      ''
        ${adminCmd} create --admin --email "root@localhost" --username ${user} --password "$(tr -d '\n' < ${pwd})" || true
      '';
  };
}
