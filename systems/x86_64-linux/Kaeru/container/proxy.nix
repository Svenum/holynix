{ config, ... }:

{
  sops.secrets."proxy.env" = {
    sopsFile = ../../../../secrets/kaeru/container/proxy.env;
    format = "dotenv";
    key = "";
  };
  virtualisation.quadlet =
    let
      inherit (config.virtualisation.quadlet) networks;
      volumePath = "/mnt/container/proxy";
    in
    {
      containers = {
        "proxy_traefik" = {
          autoStart = true;
          containerConfig = {
            image = "docker.io/traefik:latest";
            volumes = [
              "${volumePath}/traefik:/etc/traefik"
              "/var/run/docker.sock:/var/run/docker.sock"
            ];
            networks = [
              "${networks.proxy_default.ref}"
              "${networks.proxy.ref}"
              "${networks.br0.ref}:ip=172.16.0.220"
            ];
            labels = {
              "traefik.enable" = "true";
              "traefik.http.routers.traefik.entryPoints" = "https";
              "traefik.http.services.traefik.loadbalancer.server.port" = "8080";
            };
            dns = [
              "9.9.9.9"
              "149.112.112.112"
            ];
            environmentFiles = [ config.sops.secrets."proxy.env".path ];
          };
        };
      };
      networks.proxy_default = {
        autoStart = true;
        networkConfig = {
          driver = "bridge";
          podmanArgs = [ "--network-interface=podman0" ];
        };
      };
    };
}
