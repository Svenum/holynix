{
  config,
  lib,
  ...
}:

with lib;
with lib.types;
let
  cfg = config.holynix.services.collabora;
  cfgC = config.holynix.services.cloudflared;
  cfgS = config.holynix.services;
in
{

  options.holynix.services.collabora = {
    enable = mkEnableOption "Enable collabora";
  };

  config = mkIf cfg.enable {
    services = {
      collabora-online = {
        enable = true;
        settings.server_name = "collabora.${cfgS.publicDomain}";
        aliasGroups = mkIf config.services.nextcloud.enable [
          {
            host = "https://nextcloud.${cfgS.publicDomain}";
            aliases = [ "https://nextcloud.${cfgS.privateDomain}" ];
          }
        ];
      };
      cloudflared.tunnels."${cfgC.tunnelId}".ingress."collabora.${cfgS.publicDomain}" =
        mkIf cfgC.enable "https://collabora.${cfgS.privateDomain}";
      caddy = {
        enable = true;
        virtualHosts."collabora.${cfgS.publicDomain}" = {
          serverAliases = [ "collabora.${cfgS.privateDomain}" ];
          extraConfig = ''
            reverse_proxy https://localhost:${toString config.services.collabora-online.port}{
              transport http {
                  tls_insecure_skip_verify
              }
            }
          '';
        };
      };
    };
  };
}
