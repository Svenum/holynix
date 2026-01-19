{ config, ... }:

{
  virtualisation.quadlet =
    let
      inherit (config.virtualisation.quadlet) networks;
      volumePath = "/mnt/container/proxy";
    in
    {
      sops.secrets."proxy.yaml" = {
        sopsFile = ../../../../secrets/kaeru/container/proxy.yaml;
        format = "binary";
      };
      containers = {
        "proxy-traefik" = {
          autoStart = true;
          containerConfig = {
            image = "docker.io/traefik:latest";
            volumes = [
              "${volumePath}/traefik:/etc/traefik"
              "/var/run/docker.sock:/var/run/docker.sock"
            ];
            networks = [
              "default"
              networks.proxy.ref
            ];
            environments = {
              CLOUDFLARE_EMAIL = "$${CLOUDFLARE_EMAIL}";
              CLOUDFLARE_DNS_API_TOKEN = "$${CLOUDFLARE_DNS_API_TOKEN}";
            };
            ip = "172.16.0.220";
            labels = {
              "traefik.enable" = true;
              "traefik.http.routers.traefik.entryPoint" = "https";
              "traefik.http.services.traefik.loadbalancer.server.port" = 8080;
            };
            dns = [
              "9.9.9.9"
              "149.112.112.112"
            ];
            environmentFiles = [ config.sops.secrets."proxy.yaml".path ];
          };
        };
      };
    };
}
