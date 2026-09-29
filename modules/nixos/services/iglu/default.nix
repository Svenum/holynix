{ lib, config, ... }:

with lib;
with lib.types;
let
  cfg = config.holynix.services.iglu;
  cfgS = config.holynix.services;
  cfgC = config.holynix.services.cloudflared;
in
{
  options.holynix.services.iglu = {
    enable = mkEnableOption "Enable iglu service";
  };

  config = mkIf cfg.enable {
    sops.secrets."services/iglu/hashing_secret" = {
      restartUnits = [ "iglu-cache.service" ];
      owner = "iglu";
      group = "iglu";
    };
    services = {
      cloudflared.tunnels."${cfgC.tunnelId}".ingress."iglu.${cfgS.publicDomain}" =
        mkIf cfgC.enable "https://iglu.${cfgS.privateDomain}";
      iglu-cache = {
        enable = true;
        database = {
          type = "postgres";
          createLocally = true;
        };
        settings = {
          server = {
            hostname = "https://iglu.${cfgS.publicDomain}";
            port = 8082;
            hashing_secret_file = config.sops.secrets."services/iglu/hashing_secret".path;
          };
          tenants.definitions = [
            {
              name = "default";
              github_username = "Svenum";
              is_public = true;
            }
          ];
        };
      };
      caddy = {
        enable = true;
        virtualHosts."iglu.${cfgS.publicDomain}" = {
          serverAliases = [ "iglu.${cfgS.privateDomain}" ];
          extraConfig = ''
            reverse_proxy localhost:${toString config.services.iglu-cache.settings.server.port}
          '';
        };
      };
    };
  };
}
