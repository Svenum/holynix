{ lib, config, ... }:

with lib;
with lib.types;
let
  cfg = config.holynix.services.vaultwarden;
  cfgS = config.holynix.services;
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
    services.vaultwarden = {
      enable = true;
      dbBackend = "postgresql";
      config = {
        DATABASE_URL = "postgresql:///vaultwarden?host=/run/postgresql";
        DOMAIN = "https://vaultwarden.${cfgS.publicDomain}";
        ENABLE_WEBSOCKET = true;
        ROCKET_ADDRESS = "127.0.0.1";
        ROCKET_PORT = lib.mkDefault 8222;
      };
      configurePostgres = true;
      inherit (cfg) environmentFile;
    };

    services.caddy = {
      enable = true;
      virtualHosts."vaultwarden.${cfgS.publicDomain}" =
        let
          port = toString config.services.vaultwarden.config.ROCKET_PORT;
        in
        {
          serverAliases = [ "vaultwarden.${cfgS.privateDomain}" ];
          extraConfig = ''
            reverse_proxy /notifications/anonymous-hub http://127.0.0.1:${port} {
              websocket
            }

            reverse_proxy /notifications/hub http://127.0.0.1:${port} {
              websocket
            }

            reverse_proxy http://127.0.0.1:${port}
          '';
        };
    };
  };
}
