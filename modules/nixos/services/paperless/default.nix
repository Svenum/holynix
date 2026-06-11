{
  lib,
  config,
  ...
}:

with lib;
with lib.types;
let
  cfg = config.holynix.services.paperless;
  cfgS = config.holynix.services;
in
{
  options.holynix.services.paperless = {
    enable = mkEnableOption "Enable Paperless service";
    enableOidc = mkOption {
      type = bool;
      default = false;
      description = "Enable oidc for paperless";
    };
  };

  config = mkIf cfg.enable {
    sops.secrets = {
      "services/paperless/oidc" = mkIf cfg.enableOidc { };
      "services/paperless/admin_pass" = { };
    };

    services = {
      paperless = {
        enable = true;
        configureTika = true;
        database.createLocally = true;
        environmentFile = mkIf cfg.enableOidc config.sops.secrets."services/paperless/oidc".path;
        passwordFile = config.sops.secrets."services/paperless/admin_pass".path;
        domain = "paperless.${cfgS.publicDomain}";
        settings = {
          # OCR
          PAPERLESS_OCR_LANGUAGE = "deu+eng";

          # Access
          PAPERLESS_ALLOWED_HOSTS = "paperless.${cfgS.publicDomain},paperless.${cfgS.privateDomain}";
          PAPERLESS_CSRF_TRUSTED_ORIGINS = "https://paperless.${cfgS.publicDomain},https://paperless.${cfgS.privateDomain}";
          PAPERLESS_CORS_ALLOWED_HOSTS = "https://paperless.${cfgS.publicDomain},https://paperless.${cfgS.privateDomain}";

          # Filestructure
          PAPERLESS_FILENAME_FORMAT = "{{owner_username}}/{{correspondent}}/{{created_year}}/{{title}}";
        };
      };

      postgresqlBackup = {
        enable = true;
        databases = [
          "paperless"
        ];
      };

      caddy = {
        enable = true;
        virtualHosts."paperless.${cfgS.publicDomain}" = {
          serverAliases = [ "paperless.${cfgS.privateDomain}" ];
          extraConfig = ''
            reverse_proxy localhost:${toString config.services.paperless.port}

            handle /static/* {
              root * ${config.services.paperless.package}
              rewrite * /lib/paperless-ngx{path}
              file_server
            }
          '';
        };
      };
    };
  };
}
