{
  config,
  lib,
  ...
}:

with lib;
with lib.types;
let
  cfg = config.holynix.services.authentik;
  cfgS = config.holynix.services;
in
{
  options.holynix.services.authentik = {
    enable = mkEnableOption "Enable Caddy";
  };

  config = mkIf cfg.enable {
    sops.secrets = {
      "services/authentik/core" = {
        restartUnits = [ "authentik-migrate.service" ];
      };
      "services/authentik/ldap" = {
        restartUnits = [ "authentik-migrate.service" ];
      };
    };

    services = {
      authentik = {
        enable = true;
        environmentFile = config.sops.secrets."services/authentik/core".path;
      };
      authentik-ldap = {
        enable = true;
        environmentFile = config.sops.secrets."services/authentik/ldap".path;
      };
      caddy = {
        enable = true;
        virtualHosts."authentik.${cfgS.publicDomain}" = {
          serverAliases = [ "authentik.${cfgS.privateDomain}" ];
          extraConfig = ''
            reverse_proxy localhost:9443 {
              transport http {
                tls
                tls_insecure_skip_verify
              }
            }
          '';
        };
      };
      postgresqlBackup = {
        enable = true;
        databases = [
          "authentik"
        ];
      };
    };
  };
}
