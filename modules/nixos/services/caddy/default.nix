{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
with lib.types;
let
  cfg = config.holynix.services.caddy;
in
{
  options.holynix.services.caddy = {
    enable = mkOption {
      type = bool;
      default = false;
      description = "Enable caddy";
    };
  };

  config = mkIf cfg.enable {
    services.caddy = {
      enable = true;
      package = pkgs.caddy.withPlugins {
        plugins = [ "github.com/caddy-dns/cloudflare@v0.2.2" ];
        hash = "sha256-dnhEjopeA0UiI+XVYHYpsjcEI6Y1Hacbi28hVKYQURg=";
      };
      globalConfig = ''
        acme_dns cloudflare {$CLOUDFLARE_KEY}
      '';
      extraConfig = ''
        https:// {
          header {
            X-Robots-Tag "noindex,nofollow"
            -Server
            X-Forwarded-Proto "https"
            Referrer-Policy "strict-origin-when-cross-origin"
            Access-Control-Allow-Methods "OPTION, POST, GET, PUT, DELETE"
            Access-Control-Allow-Headers "*"
            Access-Control-Allow-Origin "*"
            Access-Control-Max-Age "100"
            X-Content-Type-Options "nosniff"
            X-XSS-Protection "1; mode=block"
            Strict-Transport-Security "max-age=63072000; includeSubDomains; preload"
          }
        }
      '';
    };

    sops.secrets."services/caddy/cloudflare_dns_api_token" = {
      restartUnits = [ "caddy.service" ];
    };
    systemd.services.caddy.serviceConfig.EnvironmentFile = [
      config.sops.secrets."services/caddy/cloudflare_dns_api_token".path
    ];

    networking.firewall.allowedTCPPorts = [
      80
      443
    ];
  };
}
