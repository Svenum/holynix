{
  lib,
  config,
  pkgs,
  ...
}:

with lib;
with lib.types;
let
  cfg = config.holynix.services.handbrake;
  cfgS = config.holynix.services;
in
{
  options.holynix.services.handbrake = {
    enable = lib.mkEnableOption "Enable handbrake";
  };

  imports = [
    (lib.mkIf cfg.enable (import ./docker-compose.nix { inherit config lib pkgs; }))
  ];

  config = mkIf cfg.enable {
    hardware.nvidia-container-toolkit.enable = true;
    services = {
      caddy = {
        enable = true;
        virtualHosts."handbrake.${cfgS.privateDomain}" = {
          extraConfig = ''
            reverse_proxy localhost:5800
          '';
        };
      };
    };
  };
}
