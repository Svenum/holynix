{ config, ... }:

{
  sops.secrets."cloudflare.env" = {
    sopsFile = ../../../../secrets/kaeru/container/cloudflare.env;
    format = "dotenv";
    key = "";
  };

  virtualisation.quadlet = {
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
    };
  };
}
