{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
with lib.types;
let
  cfg = config.holynix.services.it-tools;
  cfgC = config.holynix.services.cloudflared;
  cfgS = config.holynix.services;
in
{
  options.holynix.services.it-tools = {
    enable = lib.mkEnableOption "Enable it-tools";
  };

  config = mkIf cfg.enable {
    services = {
      cloudflared.tunnels."${cfgC.tunnelId}".ingress."it-tools.${cfgS.publicDomain}" =
        mkIf cfgC.enable "https://it-tools.${cfgS.privateDomain}";
      caddy = {
        enable = true;
        virtualHosts."it-tools.${cfgS.publicDomain}" = {
          serverAliases = [ "it-tools.${cfgS.privateDomain}" ];
          extraConfig = ''
            root * ${pkgs.it-tools}/lib
            file_server
          '';
        };
      };
    };
  };
}
