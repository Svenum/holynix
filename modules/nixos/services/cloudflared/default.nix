{
  config,
  lib,
  ...
}:

with lib;
with lib.types;
let
  cfg = config.holynix.services.cloudflared;
in
{
  options.holynix.services.cloudflared = {
    enable = mkEnableOption "Enable Cloudfalred tunnel";
    tunnelId = mkOption {
      type = str;
      default = "";
      description = ''
        The UUID of the tunnel
      '';
    };
  };

  config = mkIf cfg.enable {
    sops.secrets = {
      "services/cloudflared/cert".restartUnits = [ "cloudflared.service" ];
      "services/cloudflared/cred".restartUnits = [ "cloudflared.service" ];
    };

    services.cloudflared = {
      enable = true;
      tunnels."${cfg.tunnelId}" = {
        default = "http_status:404";
        certificateFile = config.sops.secrets."services/cloudflared/cert".path;
        credentialsFile = config.sops.secrets."services/cloudflared/cred".path;
      };
    };
  };
}
