{
  config,
  lib,
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
      default = config.services.caddy.enable;
      description = "Enable Caddy";
    };
    autoEnable = mkOption {
      type = bool;
      default = true;
      description = "Enable Caddy";
    };
    enableSSL = mkOption {
      type = bool;
      default = true;
      description = "Enable ssl via cloudflare.";
    };
  };

  config = mkIf cfg.enable {
    services.caddy = {
      package = pkgs.caddy.withPlugins {
        plugins = [
          "github.com/caddy-dns/cloudflare@v0.2.4"
          "github.com/mholt/caddy-l4@v0.1.2"
        ];
        hash = "sha256-eGv+I4CceOEqWrMs5fTWPrTF3DBXtB+0vu3Ndw4yArE=";
      };
      globalConfig = mkIf cfg.enableSSL ''
        acme_dns cloudflare {$CLOUDFLARE_DNS_API_TOKEN}
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
    # Should contain:
    # CLOUDFLARE_DNS_API_TOKEN=SECRET_KEY
    sops.secret = mkIf cfg.enabelSSL {
      "services/caddy/cloudflare_dns_api_token".restartUnits = [ "caddy.service" ];
    };
    systemd.services.caddy.serviceConfig.EnvironmentFile = mkIf cfg.enableSSL [
      config.sops.secrets."services/caddy/cloudflare_dns_api_token".path
    ];

    networking.firewall.allowedTCPPorts = [
      80
      443
    ];
  };
}
