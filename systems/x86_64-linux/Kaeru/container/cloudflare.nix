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
        "ddns" = {
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
              networks.proxy.ref
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
      };
    };
}
