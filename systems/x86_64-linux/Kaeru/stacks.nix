{ config, ... }:

let
  inherit (config.sops) secrets;
in
{
  sops.secrets = {
    "compose/proxy" = { };
    "compose/vpn" = { };
  };

  virtualisation.quadlet.networks = {
    "br0" = {
      autoStart = true;
      networkConfig = {
        driver = "ipvlan";
        gateways = [ "172.16.0.1" ];
        subnets = [ "172.16.0.0/24" ];
        options.parent = "br0";
      };
    };
    "proxy" = {
      autoStart = true;
      networkConfig = {
        driver = "bridge";
        internal = true;
        interfaceName = "br-proxy";
      };
    };
  };

  virtualisation.oci-containers.compose-containers = {
    "proxy" = {
      path = ./compose/proxy.yml;
      convertOptions = {
        env_files = secrets."compose/proxy".path;
        ignore_missing_env_files = true;
        include_env_files = true;
      };
    };
    "vpn" = {
      path = ./compose/vpn.yml;
      convertOptions = {
        env_files = secrets."compose/vpn".path;
        ignore_missing_env_files = true;
        include_env_files = true;
      };
    };
  };

  #holynix.services.compose = {
  #  enable = true;
  #  stacks = [
  #    {
  #      name = "proxy";
  #      envFile = secrets."compose/proxy".path;
  #      composeContent = {
  #        networks = {
  #          br0 = {
  #            external = true;
  #          };
  #          proxy = {
  #            external = true;
  #          };
  #        };

  #        services = {
  #          traefik = {
  #            image = "docker.io/traefik:latest";
  #            volumes = [
  #              "/mnt/container/proxy/traefik:/etc/traefik/"
  #              "/run/podman/podman.sock:/var/run/docker.sock"
  #            ];
  #            networks = {
  #              br0 = {
  #                ipv4_address = "172.16.0.220";
  #              };
  #              proxy = { };
  #            };
  #            environment = {
  #              CLOUDFALRE_EMAIL = "\${CLOUDFLARE_EMAIL}";
  #              CLOUDFLARE_DNS_API_TOKEN = "\${CLOUDFLARE_DNS_API_TOKEN}";

  #              # Global
  #              TRAEFIK_GLOBAL_CHECKNEWVERSION = "true";
  #              TRAEFIK_GLOBAL_SENDANONYMOUSUSAGE = "false";

  #              # Servers Transport
  #              TRAEFIK_SERVERSTRANSPORT_INSECURESKIPVERIFY = "true";

  #              # Entry Points - HTTP
  #              TRAEFIK_ENTRYPOINTS_HTTP_ADDRESS = ":80";
  #              TRAEFIK_ENTRYPOINTS_HTTP_HTTP_REDIRECTIONS_ENTRYPOINT_TO = "https";
  #              TRAEFIK_ENTRYPOINTS_HTTP_HTTP_REDIRECTIONS_ENTRYPOINT_SCHEME = "https";

  #              # Entry Points - HTTPS
  #              TRAEFIK_ENTRYPOINTS_HTTPS_ADDRESS = ":443";
  #              TRAEFIK_ENTRYPOINTS_HTTPS_HTTP_TLS_CERTRESOLVER = "letsencrypt";
  #              TRAEFIK_ENTRYPOINTS_HTTPS_HTTP_MIDDLEWARES = "securityheaders";
  #              TRAEFIK_ENTRYPOINTS_HTTPS_TRANSPORT_RESPONDINGTIMEOUTS_READTIMEOUT = "0s";

  #              # Middleware - Security Headers
  #              TRAEFIK_HTTP_MIDDLEWARES_SECURITYHEADERS_HEADERS_CUSTOMRESPONSEHEADERS_X-Robots-Tag = "noindex,nofollow";
  #              TRAEFIK_HTTP_MIDDLEWARES_SECURITYHEADERS_HEADERS_CUSTOMRESPONSEHEADERS_SERVER = "";
  #              TRAEFIK_HTTP_MIDDLEWARES_SECURITYHEADERS_HEADERS_CUSTOMRESPONSEHEADERS_X-Forwarded-Proto = "https";
  #              TRAEFIK_HTTP_MIDDLEWARES_SECURITYHEADERS_HEADERS_SSLPROXYHEADERS_X-Forwarded-Proto = "https";
  #              TRAEFIK_HTTP_MIDDLEWARES_SECURITYHEADERS_HEADERS_REFERRERPOLICY = "strict-origin-when-cross-origin";
  #              TRAEFIK_HTTP_MIDDLEWARES_SECURITYHEADERS_HEADERS_HOSTSPROXYHEADERS = "X-Forwarded-Host";
  #              TRAEFIK_HTTP_MIDDLEWARES_SECURITYHEADERS_HEADERS_CUSTOMREQUESTHEADERS_X-Forwarded-Proto = "https";
  #              TRAEFIK_HTTP_MIDDLEWARES_SECURITYHEADERS_HEADERS_ACCESSCONTROLALLOWMETHODS = "OPTION,POST,GET,PUT,DELETE";
  #              TRAEFIK_HTTP_MIDDLEWARES_SECURITYHEADERS_HEADERS_ACCESSCONTROLALLOWHEADERS = "*";
  #              TRAEFIK_HTTP_MIDDLEWARES_SECURITYHEADERS_HEADERS_ACCESSCONTROLALLOWORIGINLIST = "*";
  #              TRAEFIK_HTTP_MIDDLEWARES_SECURITYHEADERS_HEADERS_ACCESSCONTROLMAXAGE = "100";
  #              TRAEFIK_HTTP_MIDDLEWARES_SECURITYHEADERS_HEADERS_ADDVARYHEADER = "true";
  #              TRAEFIK_HTTP_MIDDLEWARES_SECURITYHEADERS_HEADERS_CONTENTTYPENOSNIFF = "true";
  #              TRAEFIK_HTTP_MIDDLEWARES_SECURITYHEADERS_HEADERS_BROWSERXSSFILTER = "true";
  #              TRAEFIK_HTTP_MIDDLEWARES_SECURITYHEADERS_HEADERS_FORCESTSHEADER = "true";
  #              TRAEFIK_HTTP_MIDDLEWARES_SECURITYHEADERS_HEADERS_STSINCLUDESUBDOMAINS = "true";
  #              TRAEFIK_HTTP_MIDDLEWARES_SECURITYHEADERS_HEADERS_STSSECONDS = "63072000";
  #              TRAEFIK_HTTP_MIDDLEWARES_SECURITYHEADERS_HEADERS_STSPRELOAD = "true";

  #              # Entry Points - LDAPS
  #              TRAEFIK_ENTRYPOINTS_LDAPS_ADDRESS = ":636";

  #              # Entry Points - SFTP Pelican
  #              TRAEFIK_ENTRYPOINTS_PELICAN_ADDRESS = ":2022";

  #              # Providers
  #              TRAEFIK_PROVIDERS_PROVIDERSTHROTTLEDURATION = "5s";

  #              # Providers - Docker
  #              TRAEFIK_PROVIDERS_DOCKER = "true";
  #              TRAEFIK_PROVIDERS_DOCKER_WATCH = "true";
  #              TRAEFIK_PROVIDERS_DOCKER_DEFAULTRULE = "Host(`{{ index .Labels \"service\" }}.kaeru.holypenguin.net`)";
  #              TRAEFIK_PROVIDERS_DOCKER_NETWORK = "proxy";
  #              TRAEFIK_PROVIDERS_DOCKER_EXPOSEDBYDEFAULT = "false";
  #              TRAEFIK_PROVIDERS_DOCKER_USEBINDPORTIP = "true";
  #              TRAEFIK_PROVIDERS_DOCKER_ALLOWEMPTYSERVICES = "false";

  #              # API
  #              TRAEFIK_API_DASHBOARD = "true";
  #              TRAEFIK_API_INSECURE = "true";

  #              # Log
  #              TRAEFIK_LOG_LEVEL = "DEBUG";

  #              # Certificate Resolvers - Let's Encrypt
  #              TRAEFIK_CERTIFICATESRESOLVERS_LETSENCRYPT_ACME_EMAIL = "\${CLOUDFLARE_EMAIL}";
  #              TRAEFIK_CERTIFICATESRESOLVERS_LETSENCRYPT_ACME_STORAGE = "/etc/traefik/acme.json";
  #              TRAEFIK_CERTIFICATESRESOLVERS_LETSENCRYPT_ACME_DNSCHALLENGE_PROVIDER = "cloudflare";
  #              TRAEFIK_CERTIFICATESRESOLVERS_LETSENCRYPT_ACME_DNSCHALLENGE_RESOLVERS = "1.1.1.1:53,1.0.0.1:53";

  #              # Experimental - Plugins
  #              TRAEFIK_EXPERIMENTAL_PLUGINS_SABLIER_MODULENAME = "github.com/sablierapp/sablier-traefik-plugin";
  #              TRAEFIK_EXPERIMENTAL_PLUGINS_SABLIER_VERSION = "v1.1.0";
  #            };
  #            dns = [
  #              "9.9.9.9"
  #              "149.112.112.112"
  #            ];
  #            labels = {
  #              "traefik.enable" = "true";
  #              "traefik.http.routers.traefik.entryPoints" = "https";
  #              "traefik.http.services.traefik.loadbalancer.server.port" = "8080";
  #              "service" = "traefik";
  #            };
  #          };

  #          sablier = {
  #            image = "docker.io/sablierapp/sablier:1.11.1";
  #            environment = {
  #              SABLIER_PROVIDER_NAME = "podman";
  #              SABLIER_SERVER_PORT = "10000";
  #              SABLIER_SERVER_BASE_PATH = "/";
  #              SABLIER_SESSIONS_DEFAULT_DURATION = "5m";
  #              SABLIER_SESSIONS_EXPIRATION_INTERVAL = "1m";
  #              SABLIER_LOGGING_LEVEL = "info";
  #              SABLIER_STRATEGY_DYNAMIC_DEFAULT_THEME = "ghost";
  #              SABLIER_STRATEGY_DYNAMIC_DEFAULT_REFRESH_FREQUENCY = "5s";
  #              SABLIER_STRATEGY_DYNAMIC_SHOW_DETAILS_BY_DEFAULT = "true";
  #            };
  #            volumes = [
  #              "/run/podman/podman.sock:/run/podman/podman.sock"
  #            ];
  #            networks = [
  #              "proxy"
  #            ];
  #          };
  #        };
  #      };
  #    }
  #  ];
  #};
}
