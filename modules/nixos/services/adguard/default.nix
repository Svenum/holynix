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
    dnsHosts = mkOption {
      type = listOf str;
      default = [ ];
      description = "IP Adresses on which the dns server will listen on.";
    };
  };

  config = mkIf cfg.enable {
    networking.nameservers = [ "127.0.0.1" ];

    services = {
      adguardhome = {
        enable = true;
        host = "0.0.0.0";
        port = 3001;
        settings =
          let
            baseConfig = import ./AdGuardHome.nix;
          in
          lib.recursiveUpdate baseConfig {
            dns.bind_hosts = [ "127.0.0.1" ] ++ cfg.dnsHosts;
            filtering.rewrites = baseConfig.filtering.rewrites ++ [
              {
                domain = "*.${cfgS.privateDomain}";
                enabled = true;
                answer = cfgS.listeningIp;
              }
              {
                domain = "${cfgS.privateDomain}";
                enabled = true;
                answer = cfgS.listeningIp;
              }
              {
                domain = "*.${cfgS.publicDomain}";
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
