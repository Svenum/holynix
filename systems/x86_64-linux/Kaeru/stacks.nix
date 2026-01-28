{ config, ... }:

let
  inherit (config.sops) secrets;
in
{
  sops.secrets = {
    "compose/proxy" = {
      owner = config.holynix.services.compose.user;
      group = config.holynix.services.compose.user;
    };
  };

  virtualisation.quadlet.networks."proxy" = {
    autoStart = true;
    networkConfig = {
      driver = "bridge";
      internal = true;
    };
  };

  holynix.services.compose = {
    enable = true;
    uid = 992;
    stacks = [
      {
        name = "proxy";
        envFile = secrets."compose/proxy".path;
        composeContent = {
          networks = {
            br0 = {
              external = true;
            };
            proxy = {
              external = true;
            };
          };

          services = {
            traefik = {
              restart = "unless-stopped";
              image = "traefik:latest";
              volumes = [
                "./proxy/traefik:/etc/traefik/"
                "/var/run/docker.sock:/var/run/docker.sock"
              ];
              networks = {
                br0 = {
                  ipv4_address = "172.16.0.10";
                };
                proxy = { };
              };
              environment = {
                CLOUDFALRE_EMAIL = "\${CLOUDFLARE_EMAIL}";
                CLOUDFLARE_DNS_API_TOKEN = "\${CLOUDFLARE_DNS_API_TOKEN}";
              };
              dns = [
                "9.9.9.9"
                "149.112.112.112"
              ];
              labels = {
                "traefik.enable" = "true";
                "traefik.http.routers.traefik.entryPoints" = "https";
                "traefik.http.services.traefik.loadbalancer.server.port" = "8080";
              };
            };

            sablier = {
              restart = "unless-stopped";
              image = "sablierapp/sablier:1.8.5";
              environment = {
                PROVIDER_NAME = "docker";
                SERVER_PORT = "10000";
                SERVER_BASE_PATH = "/";
                SESSIONS_DEFAULT_DURATION = "5m";
                SESSIONS_EXPIRATION_INTERVAL = "1m";
                LOGGING_LEVEL = "info";
                STRATEGY_DYNAMIC_DEFAULT_THEME = "ghost";
                STRATEGY_DYNAMIC_DEFAULT_REFRESH_FREQUENCY = "5s";
                STRATEGY_DYNAMIC_SHOW_DETAILS_BY_DEFAULT = "true";
              };
              volumes = [
                "/var/run/docker.sock:/var/run/docker.sock"
              ];
              networks = [
                "proxy"
              ];
            };
          };
        };
      }
    ];
  };
}
