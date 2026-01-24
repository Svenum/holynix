{
  config,
  lib,
  ...
}:

with lib;
with lib.types;
let
  cfg = config.holynix.services.nextcloud;
  inherit (config.sops) secrets;
in
{

  options.holynix.services.nextcloud = {
    enable = mkOption {
      type = bool;
      default = false;
      description = "Enable nextcloud";
    };
  };
  config = mkIf cfg.enable {
    sops.secrets."services/nextcloud/adminpass" = { };
    services.nextcloud = {
      enable = true;
      hostName = "nextcloud.${config.holynix.services.globalSettings.domain}";
      config = {
        adminuser = config.holynix.services.globalSettings.adminName;
        adminpassFile = secrets."services/nextcloud/adminpass".path;
      };
    };
  };
}
