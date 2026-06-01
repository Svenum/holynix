{ lib, config, ... }:
with lib;
with lib.types;
let
  cfg = config.holynix.services.adguard;
  cfgS = config.holynix.services;
in
{
  options.holynix.services.adguard = {
    enable = mkEnableOption "Enable Adguard service";
  };

  config = mkIf cfg.enable {
    services = {
      adguardhome = {
        enable = true;
        host = "https://adguard.${cfgS.publicDomain}";
      };

      caddy = {
        enable = true;
        virtualHosts."adguard.${cfgS.publicDomain}" =
          let
            port = toString config.services.adguardhome.port;
          in
          {
            serverAliases = [ "adguard.${cfgS.privateDomain}" ];
            extraConfig = ''
              reverse_proxy http://127.0.0.1:${port}
            '';
          };
      };
    };
  };
}
