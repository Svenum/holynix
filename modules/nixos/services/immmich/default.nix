{
  config,
  lib,
  ...
}:

with lib;
with lib.types;
let
  cfg = config.holynix.services.immich;
  cfgC = config.holynix.services.cloudflared;
  cfgS = config.holynix.services;
in
{

  options.holynix.services.immich = {
    enable = mkEnableOption "Enable Immich";

    oauth = {
      enable = mkOption {
        type = bool;
        default = false;
        description = "Enable oauth for Immich";
      };
      issuerUrl = mkOption {
        type = str;
        default = "";
        description = "Issuere URL for Immich oauth";
      };
    };
  };

  config = mkIf cfg.enable {
    sops.secrets = {
      "services/immich/client_id".restartUnits = [ "immich-server.service" ];
      "services/immich/client_secret".restartUnits = [ "immich-server.service" ];
    };
    services = {
      immich = {
        enable = true;
        accelerationDevices = [ "/dev/dri/renderD128" ];
        settings = {
          server = {
            externalDomain = "https://immich.${cfgS.publicDomain}";
          };
          oauth = mkIf cfg.oauth.enable {
            autoRegister = true;
            buttonText = "Authentik";
            clientId._secret = config.sops.secrets."services/immich/client_id".path;
            clientSecret._secret = config.sops.secrets."services/immich/client_secret".path;
            defaultStorageQuota = 100;
            enabled = true;
            issuerUrl = cfg.oauth.issuerUrl;
            timeout = 30000;
          };
        };
      };
      cloudflared.tunnels."${cfgC.tunnelId}".ingress."immich.${cfgS.publicDomain}" =
        mkIf cfgC.enable "https://immich.${cfgS.privateDomain}";
      postgresqlBackup = {
        enable = true;
        databases = [
          "immich"
        ];
      };
      caddy = {
        enable = true;
        virtualHosts."immich.${cfgS.publicDomain}" = {
          serverAliases = [ "immich.${cfgS.privateDomain}" ];
          extraConfig = ''
            reverse_proxy http://localhost:${toString config.services.immich.port}
          '';
        };
      };
    };
  };
}
