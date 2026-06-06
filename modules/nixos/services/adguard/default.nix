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
    networking.nameservers = [ "127.0.0.1" ];

    services = {
      adguardhome = {
        enable = true;
        host = "0.0.0.0";
        settings =
          let
            baseConfig = import ./AdGuardHome.nix;
          in
          lib.recursiveUpdate baseConfig {
            filtering.rewrites = baseConfig.filtering.rewrites ++ [
              {
                domain = "*.${cfgS.privateDomain}";
                enabled = true;
                answer = cfgS.listeningIp;
              }
            ];
          };
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
