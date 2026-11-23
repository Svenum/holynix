{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
with lib.types;
let
  cfg = config.holynix.services.darts;
  cfgS = config.holynix.services;
  cfgC = config.holynix.services.cloudflared;
in
{
  options.holynix.services.darts = {
    enable = lib.mkEnableOption "Enable darts.";
  };

  imports = [
    (lib.mkIf cfg.enable (import ./docker-compose.nix { inherit config lib pkgs; }))
  ];

  config = mkIf cfg.enable {

    virtualisation.oci-containers.containers = {
      "darts-darts" = {
        environment = {
          PUBLIC_URL = "https://darts.${cfgS.publicDomain}";
        };
      };
    };

    services = {
      cloudflared.tunnels."${cfgC.tunnelId}".ingress."darts.${cfgS.publicDomain}" =
        mkIf cfgC.enable "https://darts.${cfgS.privateDomain}";
      caddy = {
        enable = true;
        virtualHosts."darts.${cfgS.privateDomain}" = {
          serverAliases = [ "darts.${cfgS.publicDomain}" ];
          extraConfig = ''
            reverse_proxy localhost:8345
          '';
        };
      };
    };
  };
}
