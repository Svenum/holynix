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
    enable = lib.mkEnableOption "Enable stirlingpdf.";
    enableOAuth = lib.mkEnableOption "Enable SSO for stirlingpdf.";
  };

  config = mkIf cfg.enable {
    sops.secrets = mkIf cfg.enableOAuth {
      "services/stirlingpdf/oauth".restartUnits = [ "stirling-pdf.service" ];
    };

    services = {
      stirling-pdf = {
        enable = true;
        environment = {
          SERVER_PORT = 3939;
          SERVER_HOST = "127.0.0.1";
          DISABLE_ADDITIONAL_FEATURES = false;
          SYSTEM_BACKENDURL = "https://pdf.${cfgS.publicDomain}";
          SECURITY_OAUTH2_ENABLED = cfg.enableOAuth;
          SECURITY_ENABLELOGIN = cfg.enableOAuth;
          SECURITY_OAUTH2_AUTOCREATEUSER = true;
          SECURITY_OAUTH2_SCOPES = "openid, profile, email";
          SECURITY_OAUTH2_USEASUSERNAME = "email";
        };
        environmentFiles = mkIf cfg.enableOAuth [
          config.sops.secrets."services/stirlingpdf/oauth".path
        ];
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
