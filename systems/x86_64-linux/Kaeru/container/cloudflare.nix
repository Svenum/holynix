{ config, ... }:

{
  sops.secrets."cloudflare.env" = {
    sopsFile = ../../../../secrets/kaeru/container/cloudflare.env;
    format = "dotenv";
    key = "";
  };

  virtualisation.quadlet =
    let
      inherit (config.virtualisation.quadlet) networks;
    in
    {
      containers = {
        "cloudflare_ddns" = {
          autoStart = true;
          containerConfig = {
            image = "docker.io/favonia/cloudflare-ddns:latest";
            environments = {
              PROXIED = "false";
              IP6_PROVIDER = "none";
            };
            environmentFiles = [ config.sops.secrets."cloudflare.env".path ];
            networks = [
              "host"
            ];
            addCapabilities = [
              "SETUID"
              "SETGID"
            ];
            dropCapabilities = [ "all" ];
            noNewPrivileges = true;
            readOnly = true;
          };
        };
        "cloudflare_tunnel" = {
          autoStart = false;
          containerConfig = {
            image = "docker.io/cloudflare/cloudflared:latest";
            environmentFiles = [ config.sops.secrets."cloudflare.env".path ];
            networks = [
              networks.proxy.ref
              networks.cloudflare_default.ref
            ];
            exec = "tunnel run";
            dns = [
              "172.16.0.3"
              "172.16.0.4"
            ];
          };
        };
      };
      networks.cloudflare_default = {
        autoStart = true;
        networkConfig = {
          driver = "bridge";
          interfaceName = "pod_cloudflare";
        };
      };
    };
}
