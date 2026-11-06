{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
with lib.types;
let
  cfg = config.holynix.services.artcraft;
  cfgC = config.holynix.services.cloudflared;
  cfgS = config.holynix.services;
in
{
  options.holynix.services.artcraft = {
    enable = lib.mkEnableOption "Enable Art Craft.";
  };

  imports = [
    (lib.mkIf cfg.enable (import ./docker-compose.nix { inherit config lib pkgs; }))
  ];
  config = mkIf cfg.enable {
    services = {
      cloudflared.tunnels."${cfgC.tunnelId}".ingress."artcraft.${cfgS.publicDomain}" =
        mkIf cfgC.enable "https://artcraft.${cfgS.privateDomain}";

      caddy = {
        enable = true;
        virtualHosts."artcraft.${cfgS.privateDomain}" = {
          extraConfig = ''
            import authentik
            reverse_proxy localhost:3012
          '';
        };
      };
    };
  };
}
