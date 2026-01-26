{
  config,
  lib,
  ...
}:

with lib;
with lib.types;
let
  cfg = config.holynix.services.authentik;
in
{
  options.holynix.services.authentik = {
    enable = mkOption {
      type = bool;
      default = false;
      description = "Enable Authentik";
    };
    enableLdap = mkOption {
      type = bool;
      default = false;
      description = "Enable LDAP Outpost";
    };
  };

  config = mkIf cfg.enable {
    sops.secrets."services/authentik/env".restartUnits = [ "authentik.service" ];
    services = {
      authentik = {
        enable = true;
        environmentFile = config.sops.secrets."services/authentik/env".path;
        settings = {
          disable_startup_analytics = true;
          avatars = "initials";
        };
      };
      caddy = {
        virtualHosts."authentik.${config.holynix.services.globalSettings.hostFQDN}" = {
          serverAliases = [ "authentik.${config.holynix.services.globalSettings.domain}" ];
          extraConfig = ''
            reverse_proxy localhost:9000 
          '';
        };
      };
    };
  };
}
