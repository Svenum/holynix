{ config, ... }:

{
  sops.secrets."proxy.env" = {
    sopsFile = ../../../../secrets/kaeru/container/proxy.env;
    format = "dotenv";
    key = "";
  };
  virtualisation.quadlet =
    let
      inherit (config.virtualisation.quadlet) networks volumes;
      volumePath = "/mnt/container/proxy";
    in
    {
      containers = {
        "proxy_traefik" = {
          autoStart = true;
          containerConfig = {
            image = "docker.io/traefik:latest";
            volumes = [
              "${volumes.proxy_traefik.ref}:/etc/traefik"
              "/var/run/docker.sock:/var/run/docker.sock"
            ];
            networks = [
              "${networks.proxy_default.ref}"
              "${networks.proxy.ref}"
              "${networks.br0.ref}:ip=172.16.0.220"
            ];
            labels = {
              "service" = "traefik";
              "traefik.enable" = "true";
              "traefik.http.routers.traefik.entryPoints" = "https";
              "traefik.http.services.traefik.loadbalancer.server.port" = "8080";
            };
            dns = [
              "9.9.9.9"
              "149.112.112.112"
            ];
            environmentFiles = [ config.sops.secrets."proxy.env".path ];
            environments = {
              # Global
              TRAEFIK_GLOBAL_CHECKNEWVERSION = "true";
              TRAEFIK_GLOBAL_SENDANONYMOUSUSAGE = "false";

              # Servers Transport
              TRAEFIK_SERVERSTRANSPORT_INSECURESKIPVERIFY = "true";

              # Entry Points - HTTP
              TRAEFIK_ENTRYPOINTS_HTTP_ADDRESS = ":80";
              TRAEFIK_ENTRYPOINTS_HTTP_HTTP_REDIRECTIONS_ENTRYPOINT_TO = "https";
              TRAEFIK_ENTRYPOINTS_HTTP_HTTP_REDIRECTIONS_ENTRYPOINT_SCHEME = "https";

              # Entry Points - HTTPS
              TRAEFIK_ENTRYPOINTS_HTTPS_ADDRESS = ":443";
              TRAEFIK_ENTRYPOINTS_HTTPS_HTTP_TLS_CERTRESOLVER = "letsencrypt";
              TRAEFIK_ENTRYPOINTS_HTTPS_HTTP_MIDDLEWARES = "securityHeaders";
              TRAEFIK_ENTRYPOINTS_HTTPS_TRANSPORT_RESPONDINGTIMEOUTS_READTIMEOUT = "0s";

              # Middleware - Security Headers
              TRAEFIK_HTTP_MIDDLEWARES_SECURITYHEADERS_HEADERS_CUSTOMRESPONSEHEADERS_X-Robots-Tag = "noindex,nofollow";
              TRAEFIK_HTTP_MIDDLEWARES_SECURITYHEADERS_HEADERS_CUSTOMRESPONSEHEADERS_SERVER = "";
              TRAEFIK_HTTP_MIDDLEWARES_SECURITYHEADERS_HEADERS_CUSTOMRESPONSEHEADERS_X-Forwarded-Proto = "https";
              TRAEFIK_HTTP_MIDDLEWARES_SECURITYHEADERS_HEADERS_SSLPROXYHEADERS_X-Forwarded-Proto = "https";
              TRAEFIK_HTTP_MIDDLEWARES_SECURITYHEADERS_HEADERS_REFERRERPOLICY = "strict-origin-when-cross-origin";
              TRAEFIK_HTTP_MIDDLEWARES_SECURITYHEADERS_HEADERS_HOSTSPROXYHEADERS = "X-Forwarded-Host";
              TRAEFIK_HTTP_MIDDLEWARES_SECURITYHEADERS_HEADERS_CUSTOMREQUESTHEADERS_X-Forwarded-Proto = "https";
              TRAEFIK_HTTP_MIDDLEWARES_SECURITYHEADERS_HEADERS_ACCESSCONTROLALLOWMETHODS = "OPTION,POST,GET,PUT,DELETE";
              TRAEFIK_HTTP_MIDDLEWARES_SECURITYHEADERS_HEADERS_ACCESSCONTROLALLOWHEADERS = "*";
              TRAEFIK_HTTP_MIDDLEWARES_SECURITYHEADERS_HEADERS_ACCESSCONTROLALLOWORIGINLIST = "*";
              TRAEFIK_HTTP_MIDDLEWARES_SECURITYHEADERS_HEADERS_ACCESSCONTROLMAXAGE = "100";
              TRAEFIK_HTTP_MIDDLEWARES_SECURITYHEADERS_HEADERS_ADDVARYHEADER = "true";
              TRAEFIK_HTTP_MIDDLEWARES_SECURITYHEADERS_HEADERS_CONTENTTYPENOSNIFF = "true";
              TRAEFIK_HTTP_MIDDLEWARES_SECURITYHEADERS_HEADERS_BROWSERXSSFILTER = "true";
              TRAEFIK_HTTP_MIDDLEWARES_SECURITYHEADERS_HEADERS_FORCESTSHEADER = "true";
              TRAEFIK_HTTP_MIDDLEWARES_SECURITYHEADERS_HEADERS_STSINCLUDESUBDOMAINS = "true";
              TRAEFIK_HTTP_MIDDLEWARES_SECURITYHEADERS_HEADERS_STSSECONDS = "63072000";
              TRAEFIK_HTTP_MIDDLEWARES_SECURITYHEADERS_HEADERS_STSPRELOAD = "true";

              # Entry Points - LDAPS
              TRAEFIK_ENTRYPOINTS_LDAPS_ADDRESS = ":636";

              # Entry Points - SFTP Pelican
              TRAEFIK_ENTRYPOINTS_SFTP_PELICAN_ADDRESS = ":2022";

              # Providers
              TRAEFIK_PROVIDERS_PROVIDERSTHROTTLEDURATION = "5s";

              # Providers - Docker
              TRAEFIK_PROVIDERS_DOCKER = "true";
              TRAEFIK_PROVIDERS_DOCKER_WATCH = "true";
              TRAEFIK_PROVIDERS_DOCKER_DEFAULTRULE = "Host(`{{ index .Labels \"service\" }}.kaeru.holypenguin.net`)";
              TRAEFIK_PROVIDERS_DOCKER_NETWORK = "proxy";
              TRAEFIK_PROVIDERS_DOCKER_EXPOSEDBYDEFAULT = "false";
              TRAEFIK_PROVIDERS_DOCKER_USEBINDPORTIP = "true";
              TRAEFIK_PROVIDERS_DOCKER_ALLOWEMPTYSERVICES = "false";

              # API
              TRAEFIK_API_DASHBOARD = "true";
              TRAEFIK_API_INSECURE = "true";

              # Log
              TRAEFIK_LOG_LEVEL = "INFO";

              # Certificate Resolvers - Let's Encrypt
              TRAEFIK_CERTIFICATESRESOLVERS_LETSENCRYPT_ACME_STORAGE = "/etc/traefik/acme.json";
              TRAEFIK_CERTIFICATESRESOLVERS_LETSENCRYPT_ACME_DNSCHALLENGE_PROVIDER = "cloudflare";
              TRAEFIK_CERTIFICATESRESOLVERS_LETSENCRYPT_ACME_DNSCHALLENGE_RESOLVERS = "1.1.1.1:53,1.0.0.1:53";

              # Experimental - Plugins
              TRAEFIK_EXPERIMENTAL_PLUGINS_SABLIER_MODULENAME = "github.com/sablierapp/sablier-traefik-plugin";
              TRAEFIK_EXPERIMENTAL_PLUGINS_SABLIER_VERSION = "v1.1.0";
            };
          };
        };
      };
      volumes.proxy_traefik.volumeConfig = {
        type = "bind";
        device = "${volumePath}/traefik";
      };
      networks.proxy_default = {
        autoStart = true;
        networkConfig = {
          driver = "bridge";
          interfaceName = "pod_proxy";
        };
      };
    };
}
