{ lib, config, ... }:

with lib;
with lib.types;
let
  cfg = config.holynix.services.tailscale;
  isServer = config.holynix.systemType.server.enable;
  plasmaCfg = config.holynix.desktop.plasma;
in
{
  options.holynix.services.tailscale = {
    enable = mkEnableOption "Enable Tailscale service";
    useAuthKeyFile = mkOption {
      type = bool;
      default = true;
      description = "A file containing the auth key";
    };
    advertiseRoutes = mkOption {
      type = listOf str;
      default = [ ];
      description = "routes that should be advertised";
    };
    enableSSH = mkOption {
      type = bool;
      default = isServer;
      description = "Enable ssh over tailscale";
    };
    acceptDNS = mkOption {
      type = bool;
      default = false;
      description = "Accept tailscale dns servers";
    };
    advertiseExitNode = mkOption {
      type = bool;
      default = isServer;
      description = "Advertise as exit node";
    };
    overrideHostname = mkOption {
      type = bool;
      default = isServer;
      description = "Override the Hostname";
    };
  };

  config = mkIf cfg.enable {
    sops.secrets = mkIf cfg.useAuthKeyFile {
      "services/tailscale/authKey".restartUnits = [
        "tailscaled.service"
      ];
    };
    services.tailscale = {
      enable = true;
      useRoutingFeatures = if isServer then "server" else "both";
      authKeyFile = mkIf cfg.useAuthKeyFile config.sops.secrets."services/tailscale/authKey".path;
      extraSetFlags =
        lists.optional cfg.advertiseExitNode "--advertise-exit-node"
        ++ lists.optional cfg.overrideHostname "--hostname=srv-${config.networking.hostName}"
        ++ lists.optional cfg.enableSSH "--ssh"
        ++ lists.optional cfg.acceptDNS "--accept-dns=true"
        ++
          lists.optional (cfg.advertiseRoutes != [ ])
            "${lib.concatStringsSep " " (map (x: "--advertise-routes=" + x) cfg.advertiseRoutes)}";
    };
    networking.firewall = {
      trustedInterfaces = [ "tailscale0" ];
      checkReversePath = "loose";
    };
    environment.systemPackages = mkIf plasmaCfg.enable [
      pkgs.tail-tray
    ];
  };
}
