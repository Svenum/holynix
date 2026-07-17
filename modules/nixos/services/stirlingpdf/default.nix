{
  lib,
  config,
  ...
}:

with lib;
with lib.types;
let
  cfg = config.holynix.services.stirlingpdf;
  cfgC = config.holynix.services.cloudflared;
  cfgS = config.holynix.services;
in
{
  options.holynix.services.stirlingpdf = {
    enable = lib.mkEnableOption "Enable stirlingpdf";
  };

  config = mkIf cfg.enable {
    services = {
      stirling-pdf = {
        enable = true;
        environment = {
          SERVER_PORT = 3939;
          SERVER_HOST = "127.0.0.1";
          SECURITY_ENABLELOGIN = false;
          DISABLE_ADDITIONAL_FEATURES = false;
        };
      };
      cloudflared.tunnels."${cfgC.tunnelId}".ingress."pdf.${cfgS.publicDomain}" =
        mkIf cfgC.enable "https://pdf.${cfgS.privateDomain}";
      caddy = {
        enable = true;
        virtualHosts."pdf.${cfgS.publicDomain}" = {
          serverAliases = [ "pdf.${cfgS.privateDomain}" ];
          extraConfig = ''
            reverse_proxy localhost:${toString config.services.stirling-pdf.environment.SERVER_PORT}
          '';
        };
      };
    };
  };
}
