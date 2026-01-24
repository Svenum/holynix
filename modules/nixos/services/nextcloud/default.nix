{
  config,
  lib,
  pkgs,
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
    sops.secrets."service_nextcloud".sopsFile =
      "${config.holynix.services.globalSettings.sopsDir}/nextcloud.yaml";
    services.nextcloud = {
      enable = true;
      hostName = "nextcloud.${config.holynix.services.globalSettings.domain}";
      config = {
        inherit (secrets."service_nextcloud") adminuser;
        adminpassFile = pkgs.writeTextFile {
          text = secrets."service_nextcloud".adminpass;
        };
      };
    };
  };
}
