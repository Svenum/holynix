{ config, lib, ... }:

with lib;
with lib.types;
let
  cfg = config.holynix.services.pelican;
  cfgC = config.holynix.services.cloudflared;
  cfgS = config.holynix.services;
in
{
  imports = [
    ./pelican-panel.nix
    ./pelican-wings.nix
  ];

  options.holynix.services.pelican = {
    enable = mkEnableOption "Enable pelican.";
    oauth = {
      enable = mkEnableOption "Enable oauth.";
      name = mkOption {
        type = str;
        default = "Authentik";
        description = "Name of the OAuth provider.";
      };
    };
  };

  config = mkIf cfg.enable {

    sops.secrets = {
      "services/pelican/wings" = { };
      "services/pelican/panel" = { };
    };

    services = {
      cloudflared.tunnels."${cfgC.tunnelId}".ingress."pelican.${cfgS.publicDomain}" =
        mkIf cfgC.enable "https://pelican.${cfgS.privateDomain}";

      pelican-panel = {
        enable = true;
        database.type = "pgsql";
        domain = "https://pelican.${cfgS.publicDomain}";
        environment = {
          TRUSTED_PROXIES = "127.0.0.1";
          "OAUTH_${toUpper cfg.oauth.name}_ENABLE" = cfg.oauth.enable;
          "OAUTH_${toUpper cfg.oauth.name}_DISPLAY_NAME" = cfg.oauth.name;
          "OAUTH_${toUpper cfg.oauth.name}_SHOULD_CREATE_MISSING_USERS" = true;
          "OAUTH_${toUpper cfg.oauth.name}_SHOULD_LINK_MISSING_USERS" = false;
        };
        secretEnvironmentFile = config.sops.secrets."services/pelican/panel".path;
      };
      pelican-wings = {
        enable = true;
        containerBackend = "podman";
        configuration = {
          remote = "https://pelican.${cfgS.publicDomain}";
          docker.network = {
            interface = "10.88.254.1";
            interfaces.v4 = {
              subnet = "10.88.254.0/24";
              gateway = "10.88.254.1";
            };
          };
        };
        secretConfigurationFile = config.sops.secrets."services/pelican/wings".path;
      };

      postgresqlBackup = {
        enable = true;
        databases = [
          "panel"
        ];
      };

      caddy = {
        enable = true;
        virtualHosts = {
          "pelican.${cfgS.publicDomain}" = {
            serverAliases = [ "pelican.${cfgS.privateDomain}" ];
            extraConfig = ''
              reverse_proxy localhost:${toString config.services.pelican-panel.port}
            '';
          };
          "wings.pelican.${cfgS.publicDomain}" = {
            serverAliases = [ "wings.pelican.${cfgS.privateDomain}" ];
            extraConfig = ''
              reverse_proxy localhost:${toString config.services.pelican-wings.apiPort}
            '';
          };
        };
      };
    };
  };
}
