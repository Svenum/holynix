{ lib, config, ... }:

with lib;
with lib.types;
let
  cfg = config.holynix.services.vaultwarden;
  cfgS = config.holynix.services;
  cfgC = config.holynix.services.cloudflared;
in
{
  options.holynix.services.vaultwarden = {
    enable = mkEnableOption "Enable Vaultwarden service";
    environmentFile = mkOption {
      type = listOf path;
      default = [ ];
      description = "Additional environment file or files";
    };
  };

  config = mkIf cfg.enable {
    sops.secrets = {
      # Should contain:
      # ADMIN_TOKEN=SECRET_TOKEN
      "services/vaultwarden/admin_token" = {
        restartUnits = [ "vaultwarden.service" ];
      };
      # Additional settings:
      # PUSH_ENABLED=true
      # PUSH_INSTALLATION_ID=SECRET
      # PUSH_INSTALLATION_KEY=SECRET
      # PUSH_RELAY_URI=https://api.bitwarden.eu
      # PUSH_IDENTITY_URI=https://identity.bitwarden.eu
      # EXPERIMENTAL_CLIENT_FEATURE_FLAGS=ssh-key-vault-item,ssh-agent
      "services/vaultwarden/settings" = {
        restartUnits = [ "vaultwarden.service" ];
      };
    };

    services = {
      cloudflared.tunnels."${cfgC.tunnelId}".ingress."bitwarden.${cfgS.publicDomain}" =
        mkIf cfgC.enable "https://vaultwarden.${cfgS.privateDomain}";
      vaultwarden = {
        enable = true;
        dbBackend = "postgresql";
        config = {
          DATABASE_URL = "postgresql:///vaultwarden?host=/run/postgresql";
          DOMAIN = "https://bitwarden.${cfgS.publicDomain}";
          ENABLE_WEBSOCKET = true;
          ROCKET_ADDRESS = "127.0.0.1";
          ROCKET_PORT = lib.mkDefault 8222;
          IP_HEADER = "X-Forwarded-For";
        };
        configurePostgres = true;
        environmentFile = [
          config.sops.secrets."services/vaultwarden/admin_token".path
          config.sops.secrets."services/vaultwarden/settings".path
        ]
        ++ cfg.environmentFile;
      };

      postgresqlBackup = {
        enable = true;
        databases = [
          "vaultwarden"
        ];
      };

      caddy = {
        enable = true;
        virtualHosts."vaultwarden.${cfgS.publicDomain}" =
          let
            port = toString config.services.vaultwarden.config.ROCKET_PORT;
          in
          {
            serverAliases = [
              "bitwarden.${cfgS.publicDomain}"
              "vaultwarden.${cfgS.privateDomain}"
            ];
            extraConfig = ''
              reverse_proxy /notifications/anonymous-hub http://127.0.0.1:${port} {
                transport http {
                  keepalive off
                }
                header_up Connection {http.request.header.Connection}
                header_up Upgrade {http.request.header.Upgrade}
              }

              reverse_proxy /notifications/hub http://127.0.0.1:${port} {
                transport http {
                  keepalive off
                }
                header_up Connection {http.request.header.Connection}
                header_up Upgrade {http.request.header.Upgrade}
              }

              reverse_proxy http://127.0.0.1:${port}
            '';
          };
      };
    };
  };
}
