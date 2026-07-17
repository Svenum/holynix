{
  config,
  lib,
  ...
}:

with lib;
with lib.types;
let
  cfg = config.holynix.services.cloudflare-ddns;
  cfgS = config.holynix.services;
in
{
  options.holynix.services.cloudflare-ddns = {
    enable = mkEnableOption "Enable Cloudfalre ddns";
  };

  config = mkIf cfg.enable {
    sops.secrets."services/cloudflare_ddns/token".restartUnits = [ "cloudflare-ddns.service" ];

    services.cloudflare-ddns = {
      enable = true;
      domains = [ "dyndns.${cfgS.publicDomain}" ];
      provider.ipv6 = "none";
      credentialsFile = config.sops.secrets."services/cloudflare_ddns/token".path;
    };
  };
}
