{
  config,
  lib,
  ...
}:

with lib;
with lib.types;
let
  cfg = config.holynix.services.authentik;
  cfgC = config.holynix.services.cloudflared;
  cfgS = config.holynix.services;
in
{
  options.holynix.services.authentik = {
    enable = mkEnableOption "Enable Authentik";
  };

  config = mkIf cfg.enable {
    sops.secrets = {
      "services/authentik/core" = {
        restartUnits = [ "authentik-migrate.service" ];
      };
      "services/authentik/ldap" = {
        restartUnits = [
          "authentik-migrate.service"
          "authentik-ldap"
        ];
      };
    };

    networking.firewall.allowedTCPPorts = [ 636 ];

    services = {
      cloudflared.tunnels."${cfgC.tunnelId}".ingress."authentik.${cfgS.publicDomain}" =
        mkIf cfgC.enable "https://authentik.${cfgS.privateDomain}";
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
        globalConfig = ''
          layer4 {
            tcp/0.0.0.0:636 {
              @ldaps tls sni authentik.${cfgS.publicDomain} authentik.${cfgS.privateDomain}
              route @ldaps {
                tls {
                }
                proxy 127.0.0.1:3389
              }
            }
          }
        '';
        extraConfig = ''
          (authentik) {
            route {
              forward_auth https://localhost:9443 {
                transport http {
                  tls
                  tls_insecure_skip_verify
                }
                uri /outpost.goauthentik.io/auth/caddy
                copy_headers Authorization X-Authentik-Username X-Authentik-Groups X-Authentik-Entitlements X-Authentik-Email X-Authentik-Name X-Authentik-Uid X-Authentik-Jwt X-Authentik-Meta-Jwks X-Authentik-Meta-Outpost X-Authentik-Meta-Provider X-Authentik-Meta-App X-Authentik-Meta-Version
                trusted_proxies private_ranges
              }
            }
          }
        '';
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
