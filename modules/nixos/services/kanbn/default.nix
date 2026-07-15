{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
with lib.types;
let
  cfg = config.holynix.services.kanbn;
  cfgC = config.holynix.services.cloudflared;
  cfgS = config.holynix.services;
in
{
  options.holynix.services.kanbn = {
    enable = lib.mkEnableOption "Enable kanbn";
  };

  imports = [
    (lib.mkIf cfg.enable (import ./docker-compose.nix { inherit config lib pkgs; }))
  ];

  config = mkIf cfg.enable {
    users = {
      users.kanbn = {
        isSystemUser = true;
        group = "kanbn";
      };
      groups.kanbn = { };
    };

    sops.secrets."services/kanbn/secrets".restartUnits = [ "podman-kanbn-web.service" ];

    virtualisation.oci-containers.containers = {
      "kanbn-web" = {
        environment = {
          NEXT_PUBLIC_BASE_URL = "kanbn.${cfgS.publicDomain}";
          NEXT_PUBLIC_ALLOW_CREDENTIALS = "true";
          NEXT_PUBLIC_DISABLE_SIGN_UP = "true";
        };
        environmentFiles = [
          config.sops.secrets."services/kanbn/secrets".path
        ];
      };
    };

    services = {
      postgresql = {
        enable = true;
        ensureDatabases = singleton "kanbn";
        ensureUsers = singleton {
          name = "kanbn";
          ensureDBOwnership = true;
        };
      };

      postgresqlBackup = {
        enable = true;
        databases = [
          "kanbn"
        ];
      };

      cloudflared.tunnels."${cfgC.tunnelId}".ingress."kanbn.${cfgS.publicDomain}" =
        mkIf cfgC.enable "https://kanbn.${cfgS.privateDomain}";
      caddy = {
        enable = true;
        virtualHosts."kanbn.${cfgS.publicDomain}" = {
          serverAliases = [ "kanbn.${cfgS.privateDomain}" ];
          extraConfig = ''
            reverse_proxy localhost:3345
          '';
        };
      };
    };
  };
}
